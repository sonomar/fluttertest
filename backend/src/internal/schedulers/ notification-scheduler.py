import json
import os
import boto3
from botocore.exceptions import ClientError
from datetime import datetime, timezone
from sqlalchemy import text # Import text for raw SQL execution
from sqlalchemy.orm import Session # Import Session for type hinting

# Import SessionLocal directly from your database.db file
from database.db import SessionLocal

# SNS Platform Application ARN (get this from your SNS console after creation)
SNS_PLATFORM_APPLICATION_ARN = os.environ.get('SNS_PLATFORM_APPLICATION_ARN')

# Initialize clients
sns_client = boto3.client('sns')

def lambda_handler(event, context):
    """
    Lambda function to process notifications based on their active status or publish date.
    It identifies notifications that need to be published (create notificationUser entries
    and send push notifications) and marks them as processed within the 'notifyData' JSON column.

    This function is intended to be triggered by an EventBridge (CloudWatch Events) schedule.
    It now directly uses SQLAlchemy's SessionLocal from database.db.
    """
    db_session: Session = None # Initialize session to None for finally block
    try:
        print(f"Scheduler Lambda triggered at: {datetime.now(timezone.utc)}")
        # Obtain SQLAlchemy database session directly from SessionLocal
        db_session = SessionLocal()

        # --- Step 1: Identify notifications to activate based on publishDt ---
        # Find notifications that are not yet active, and whose publishDt is in the past or present,
        # and have NOT been processed for push (checked via notifyData JSON).
        activate_query_sql = """
            SELECT notification_id, header, content, pushNotification, notifyData
            FROM Notification
            WHERE publishDt <= :now_utc AND active = FALSE AND JSON_EXTRACT(notifyData, '$.processedForPush') IS NULL;
        """
        now_utc = datetime.now(timezone.utc).isoformat() # ISO format for datetime string
        
        # Execute query and fetch results
        result = db_session.execute(text(activate_query_sql), {'now_utc': now_utc})
        notifications_to_activate = [row._asdict() for row in result.fetchall()] # Convert Row objects to dictionaries

        if notifications_to_activate:
            print(f"Found {len(notifications_to_activate)} notifications to activate.")
            
            # Prepare data for batch update to set active=TRUE
            activate_ids = [n['notification_id'] for n in notifications_to_activate]
            
            # Use text() with IN clause for batch update
            update_active_query_sql = """
                UPDATE Notification
                SET active = TRUE
                WHERE notification_id IN :activate_ids
            """
            db_session.execute(text(update_active_query_sql), {'activate_ids': tuple(activate_ids)})
            db_session.commit()
            print(f"Activated {len(activate_ids)} notifications.")
        else:
            print("No notifications to activate based on publishDt.")

        # --- Step 2: Identify notifications that are active but not yet processed for push ---
        # This includes notifications just activated in Step 1, and any that were
        # manually set to active=TRUE via the admin tool or direct DB change,
        # as long as they haven't been marked as processed in notifyData.
        process_query_sql = """
            SELECT notification_id, header, content, pushNotification, notifyData
            FROM Notification
            WHERE active = TRUE AND JSON_EXTRACT(notifyData, '$.processedForPush') IS NULL;
        """
        result = db_session.execute(text(process_query_sql))
        notifications_to_process = [row._asdict() for row in result.fetchall()]

        if not notifications_to_process:
            print("No new active notifications found to process.")
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'No new notifications to process.'})
            }

        print(f"Found {len(notifications_to_process)} notifications to process.")

        # Fetch all user IDs and their FCM tokens (if enabled) once
        users_query_sql = "SELECT user_id, fcm_device_token, push_notifications_enabled FROM User"
        result = db_session.execute(text(users_query_sql))
        all_users = [row._asdict() for row in result.fetchall()]
        
        users_for_notification_user_creation = [user['user_id'] for user in all_users]
        users_for_push_notification = [
            user for user in all_users
            if user['push_notifications_enabled'] and user['fcm_device_token']
        ]
        
        processed_notification_ids = []
        current_processing_dt = datetime.now(timezone.utc).isoformat() # Date for notifyData update

        for notification in notifications_to_process:
            notification_id = notification['notification_id']
            notification_title = notification['header']
            notification_body = notification['content']
            send_push = notification['pushNotification']
            # notify_data_current = notification['notifyData'] # This would be the current JSON object, if needed for complex updates

            # --- Create notificationUser entries ---
            if users_for_notification_user_creation:
                notification_user_data_for_insert = []
                for user_id in users_for_notification_user_creation:
                    # Check if notificationUser entry already exists to prevent duplicates
                    check_existing_query_sql = "SELECT COUNT(*) FROM notificationUser WHERE notificationId = :notification_id AND userId = :user_id"
                    check_result = db_session.execute(text(check_existing_query_sql), {
                        'notification_id': notification_id,
                        'user_id': user_id
                    })
                    if check_result.scalar_one() == 0: # Use scalar_one() for single value
                        notification_user_data_for_insert.append({
                            'notificationId': notification_id,
                            'userId': user_id,
                            'markRead': False,
                            'archived': False,
                            'deleted': False,
                            'pushNotification': send_push # Based on Notification's pushNotification column
                        })
                    else:
                        print(f"notificationUser entry already exists for notification {notification_id} and user {user_id}. Skipping.")

                if notification_user_data_for_insert:
                    insert_query_sql = """
                        INSERT INTO notificationUser (notificationId, userId, markRead, archived, deleted, pushNotification)
                        VALUES (:notificationId, :userId, :markRead, :archived, :deleted, :pushNotification)
                    """
                    # Use execute with a list of dictionaries for bulk insert
                    db_session.execute(text(insert_query_sql), notification_user_data_for_insert)
                    print(f"Created {len(notification_user_data_for_insert)} notificationUser entries for notification {notification_id}.")
                else:
                    print(f"No new notificationUser entries needed for notification {notification_id}.")
            else:
                print("No users found to create notificationUser entries for.")

            # --- Send Push Notifications (if enabled for this notification) ---
            if send_push and users_for_push_notification:
                print(f"Sending push notifications for notification {notification_id}.")
                for user in users_for_push_notification:
                    device_token = user['fcm_device_token']
                    try:
                        message_payload = {
                            "GCM": json.dumps({
                                "notification": {
                                    "title": notification_title,
                                    "body": notification_body,
                                    "sound": "default"
                                },
                                "data": {
                                    "notification_id": str(notification_id),
                                    "type": "new_notification_alert"
                                }
                            })
                        }

                        account_id = context.invoked_function_arn.split(':')[4]
                        region = os.environ['AWS_REGION']
                        platform_app_name = SNS_PLATFORM_APPLICATION_ARN.split('/')[-1]

                        target_arn = (
                            f"arn:aws:sns:{region}:{account_id}:"
                            f"endpoint/GCM/{platform_app_name}/"
                            f"{device_token}"
                        )

                        sns_client.publish(
                            TargetArn=target_arn,
                            Message=json.dumps(message_payload),
                            MessageStructure='json'
                        )
                        # print(f"Push notification sent to device: {device_token}") # Too verbose for many users
                    except ClientError as e:
                        print(f"SNS ClientError sending push notification to {device_token}: {e}")
                    except Exception as e:
                        print(f"Unexpected error sending push notification to {device_token}: {e}")
            elif send_push and not users_for_push_notification:
                print(f"Push enabled for notification {notification_id}, but no users with enabled push or tokens found.")
            else:
                print(f"Push not enabled for notification {notification_id}.")

            # Add to list of processed notifications
            processed_notification_ids.append(notification_id)

        # --- Step 3: Mark processed notifications by updating notifyData JSON ---
        if processed_notification_ids:
            # We need to update each notification's notifyData individually
            # to ensure JSON_SET works correctly on its existing content.
            # A single execute for multiple updates with different JSON_SET values is complex.
            # Looping is clearer here.
            for notif_id in processed_notification_ids:
                update_processed_query_sql = """
                    UPDATE Notification
                    SET notifyData = JSON_SET(COALESCE(notifyData, JSON_OBJECT()), '$.processedForPush', :processed_dt)
                    WHERE notification_id = :notification_id
                """
                db_session.execute(text(update_processed_query_sql), {
                    'processed_dt': current_processing_dt,
                    'notification_id': notif_id
                })
            db_session.commit()
            print(f"Marked {len(processed_notification_ids)} notifications as processed (notifyData updated).")
        else:
            print("No notifications were processed in this run.")

        db_session.commit() # Final commit for any remaining pending operations

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Notifications processed successfully!'})
        }

    except Exception as e:
        print(f"Lambda execution error: {e}")
        if db_session:
            db_session.rollback() # Rollback any changes on error
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f'Internal server error: {str(e)}'})
        }
    finally:
        if db_session:
            db_session.close() # Always close the session

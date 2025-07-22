import json
import boto3
from botocore.exceptions import ClientError
from datetime import datetime, timezone

from fastapi.encoders import jsonable_encoder

# Import SessionLocal directly from your database.db file
# from database.db import SessionLocal
# from sqlalchemy.orm import Session # Import Session for type hinting
# Removed: from sqlalchemy import text # No longer needed for initial query

# Import CRUD functions and schemas
import database.CRUD.GET.Notification.get_Notification_CRUD_functions as NotificationGET
import database.CRUD.PATCH.Notification.patch_Notification_CRUD_functions as NotificationPATCH
import database.CRUD.GET.User.get_User_CRUD_functions as UserGET
import database.CRUD.POST.NotificationUser.post_NotificationUser_CRUD_functions as NotificationUserPOST
import database.CRUD.GET.NotificationUser.get_NotificationUser_CRUD_functions as NotificationUserGET

from database.schema.PATCH.Notification.notification_schema import NotificationUpdate
from database.schema.POST.NotificationUser.notificationUser_schema import NotificationUserCreate
from database.schema.GET.Notification.notification_schema import NotificationResponse # For parsing GET results
from database.schema.GET.User.user_schema import UserResponse # For parsing GET results

# SNS Platform Application ARN (get this from your SNS console after creation)
# SNS_PLATFORM_APPLICATION_ARN = os.environ.get('SNS_PLATFORM_APPLICATION_ARN')
from tools.prod.prodTools import extractData, get_secrets # Adjust import path if necessary
parameters = get_secrets() # This will fetch from Secrets Manager in prod
# Initialize clients
sns_client = boto3.client('sns')

# def _create_mock_event(db_session: Session, data: dict = None, path_params: dict = None):
#     """
#     Creates a mock event dictionary that mimics the structure expected by
#     your existing API functions (which use extractData and expect db_session).
#     This is necessary when calling CRUD functions internally from a Lambda
#     that doesn't receive an API Gateway event.
#     """
#     mock_event = {
#         'body': json.dumps(data) if data is not None else '{}',
#         'pathParameters': path_params if path_params is not None else {},
#         'db_session': db_session # Inject the SQLAlchemy session
#     }
#     return mock_event

def notificationScheduler(event):
    """
    Lambda function to process notifications based on their active status or publish date.
    It identifies notifications that need to be published (create notificationUser entries
    and send push notifications) and marks them as processed within the 'notifyData' JSON column.

    This function is intended to be triggered by an EventBridge (CloudWatch Events) schedule.
    It now uses your existing CRUD functions and Pydantic schemas where applicable.
    """
    # db_session: Session = None # Initialize session to None
    db_session = event.get('db_session')
    if db_session is None:
        print("Error: db_session not found.")
    try:
        print(f"Scheduler Lambda triggered at: {datetime.now(timezone.utc)}")

        # --- Step 1: Fetch all notifications and filter them in Python ---
        # Using getAllNotifications and then filtering in Python.
        # This assumes getAllNotifications returns all necessary fields (publishDt, active, notifyData).
        # RECOMMENDATION: For large datasets, a specific GET CRUD function that filters at the DB level
        # (as in the previous direct SQL query) is more efficient.
        #data = extractData(event)
        # update the function below to be more specific
        all_notifications_response = NotificationGET.getAllNotifications(skip=0, limit=99999, db=db_session) # Assuming this function exists
        #print(jsonable_encoder(all_notifications_response))

        
        all_notifications_raw = jsonable_encoder(all_notifications_response)
        print("lawson")
        print(all_notifications_raw)
        
        notifications_to_process_raw = []
        now_utc_dt = datetime.now(timezone.utc)

        for notification in all_notifications_raw:
            notification_id = notification.get('notification_id')
            active_status = notification.get('active')
            publish_dt_str = notification.get('publishDt')
            notify_data = notification.get('notifyData') or {} # Ensure it's a dict, default to empty

            # Check if already processed for push (key 'processedForPush' exists in notifyData)
            is_processed_for_push = 'processedForPush' in notify_data

            # Convert publishDt string to datetime object for comparison
            publish_dt_obj = None
            if publish_dt_str:
                try:
                    publish_dt_obj = datetime.fromisoformat(publish_dt_str)
                except ValueError:
                    print(f"Warning: Invalid publishDt format for notification {notification_id}: {publish_dt_str}")
                    continue # Skip this notification if date is invalid

            # Criteria for processing:
            # 1. (publishDt reached AND not active) OR (already active)
            # 2. AND NOT already processed for push
            
            should_activate_by_date = publish_dt_obj and (publish_dt_obj <= now_utc_dt) and (active_status is False)
            already_active_and_needs_processing = (active_status is True) and (not is_processed_for_push)

            if (should_activate_by_date or already_active_and_needs_processing) and (not is_processed_for_push):
                notifications_to_process_raw.append(notification)

        if not notifications_to_process_raw:
            print("No new notifications found to activate or process after filtering.")
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'No new notifications to process.'})
            }

        print(f"Found {len(notifications_to_process_raw)} notifications to process after filtering.")

        processed_notification_ids = []
        current_processing_dt_iso = datetime.now(timezone.utc).isoformat()

        # Fetch all users once using CRUD function
        # RECOMMENDATION: Ideally, your UserGET CRUD would have a specific `getAllUsers` function.
        # Using `getUsersByLastLoggedIn` with a very old date and large limit as a workaround.
        # mock_get_all_users_event = _create_mock_event(
        #     db_session,
        #     data={"lastLoggedInAfter": "1970-01-01T00:00:00Z", "skip": 0, "limit": 100000} # Large limit to fetch all
        # )
        # 
        all_users_response = UserGET.getUsersByLastLoggedIn(lastLoggedInAfter= "1970-01-01T00:00:00Z", skip= 0, limit= 100000, db=db_session)
        
        #if all_users_response.get('statusCode') != 200:
        #    print(f"Failed to fetch all users: {all_users_response.get('body', 'Unknown error')}")
        #    raise Exception("Failed to retrieve user data for notification processing.")
        
        all_users_data = jsonable_encoder(all_users_response) 
        
        users_for_notification_user_creation = [user['userId'] for user in all_users_data]
        users_for_push_notification = [
            user for user in all_users_data
            if user.get('authData', {}).get('pushEnabled') == '1' and user.get('pushToken') # Check authData.pushEnabled and pushToken
        ]

        for notification_raw in notifications_to_process_raw:
            notification_id = notification_raw['notification_id']
            notification_title = notification_raw['header']
            notification_body = notification_raw['content']
            send_push = notification_raw['pushNotification']
            is_active_now = notification_raw['active']
            
            # Convert publishDt string from DB to datetime object for comparison
            publish_dt_obj = datetime.fromisoformat(notification_raw['publishDt']) if isinstance(notification_raw['publishDt'], str) else notification_raw['publishDt']
            publish_dt_reached = publish_dt_obj <= now_utc_dt

            # --- Activate notification if publishDt is reached and it's not active ---
            if publish_dt_reached and not is_active_now:
                print(f"Activating notification {notification_id} based on publishDt.")
                # Prepare data for PATCH using Pydantic schema
                # Only send 'active' field for update
                notification_update_data = NotificationUpdate(active=True)
                # mock_patch_event = _create_mock_event(
                #     db_session,
                #     data={"notificationId": notification_id, "active": True}
                # )
                patch_result = NotificationPATCH.updateNotificationByNotificationId(notificationId = notification_id, active = True, db=db_session)
                if patch_result.get('statusCode') != 200:
                    print(f"Failed to activate notification {notification_id}: {patch_result.get('body')}")
                    continue # Skip to next notification if activation fails

            # --- Create notificationUser entries ---
            if users_for_notification_user_creation:
                notification_user_data_for_insert = []
                for user_id in users_for_notification_user_creation:
                    # Check if notificationUser entry already exists to prevent duplicates
                    # RECOMMENDATION: Implement NotificationUserGET.getNotificationUsersByNotificationIdAndUserId(event)
                    # If not, a direct query is needed here.
                    # mock_get_notif_user_event = _create_mock_event(
                    #     db_session,
                    #     data={"notificationId": notification_id, "userId": user_id}
                    # )
                    existing_notif_user_response = NotificationUserGET.getNotificationUsersByNotificationIdAndUserId(notificationId = notification_id, userId = user_id, db=db_session)
                    
                    # Assuming getNotificationUsersByNotificationIdAndUserId returns a list in its body
                    if  not jsonable_encoder(existing_notif_user_response):
                        # Create Pydantic model for new entry
                        notification_user_create_payload = NotificationUserCreate(
                            notificationId=notification_id,
                            userId=user_id,
                            markRead=False,
                            archived=False,
                            deleted=False,
                            pushNotification=send_push # Based on Notification's pushNotification column
                        )
                        notification_user_data_for_insert.append(notification_user_create_payload)
                    else:
                        print(f"notificationUser entry already exists for notification {notification_id} and user {user_id}. Skipping.")

                if notification_user_data_for_insert:
                    # Loop and call createNotificationUser individually.
                    # RECOMMENDATION: Implement NotificationUserPOST.createNotificationUserBatch(list_of_schemas, db_session)
                    for nu_payload in notification_user_data_for_insert:
                        # mock_post_event = _create_mock_event(db_session, data=nu_payload.model_dump()) # Pydantic v2 .model_dump()
                        post_result = NotificationUserPOST.createNotificationUser(nu_payload.model_dump(), db=db_session)
                        if post_result.get('statusCode') != 201: # Assuming 201 for creation
                            print(f"Failed to create notificationUser for user {nu_payload.userId}: {post_result.get('body')}")
                    print(f"Attempted to create {len(notification_user_data_for_insert)} notificationUser entries for notification {notification_id}.")
                else:
                    print(f"No new notificationUser entries needed for notification {notification_id}.")
            else:
                print("No users found to create notificationUser entries for.")

            # --- Send Push Notifications (if enabled for this notification) ---
            if send_push and users_for_push_notification:
                print(f"Sending push notifications for notification {notification_id}.")
                for user in users_for_push_notification:
                    device_token = user.get('pushToken') # Access 'pushToken'
                    if device_token:
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

                            #account_id = context.invoked_function_arn.split(':')[4]
                            account_id = "125e3123625"
                            region = parameters['AWS_REGION']
                            platform_app_name = parameters["SNS_PLATFORM_APPLICATION_ARN"].split('/')[-1]

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
                        except ClientError as e:
                            print(f"SNS ClientError sending push notification to {device_token}: {e}")
                        except Exception as e:
                            print(f"Unexpected error sending push notification to {device_token}: {e}")
                    else:
                        print(f"User {user.get('userId')} has push enabled but no pushToken.")
            elif send_push and not users_for_push_notification:
                print(f"Push enabled for notification {notification_id}, but no users with enabled push or tokens found.")
            else:
                print(f"Push not enabled for notification {notification_id}.")

            # Add to list of processed notifications
            processed_notification_ids.append(notification_id)

        # --- Step 3: Mark processed notifications by updating notifyData JSON ---
        if processed_notification_ids:
            # Update each notification's notifyData individually using PATCH CRUD
            for notif_id in processed_notification_ids:
                # Get current notifyData to merge, or create new if null
                # RECOMMENDATION: Implement NotificationGET.getNotificationByNotificationId(event)
                # to return a parsed Pydantic model or directly the notifyData dict.
                current_notification_response = NotificationGET.getNotificationByNotificationId(
                    notificationId = notif_id, db=db_session
                )
                current_notify_data = {}
                #if current_notification_response.get('statusCode') == 200:
                #    current_notification_obj = json.loads(current_notification_response['body'])
                #    current_notify_data = current_notification_obj.get('notifyData', {}) or {} # Ensure it's a dict

                # Update the processedForPush key
                current_notify_data['processedForPush'] = current_processing_dt_iso

                # Prepare data for PATCH using Pydantic schema
                notification_update_payload = NotificationUpdate(notifyData=current_notify_data)
                # mock_patch_event = _create_mock_event(
                #     db_session,
                #     data={"notificationId": notif_id, "notifyData": current_notify_data}
                # )
                patch_result = NotificationPATCH.updateNotificationByNotificationId(notificationId = notif_id, notification_update_data = notification_update_payload, db=db_session)
                if patch_result.get('statusCode') != 200:
                    print(f"Failed to mark notification {notif_id} as processed: {patch_result.get('body')}")
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
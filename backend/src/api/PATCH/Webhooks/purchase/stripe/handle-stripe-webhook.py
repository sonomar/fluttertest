import json
import os
import stripe
import pymysql
from datetime import datetime

# --- Environment Variables ---
DB_HOST = os.environ.get('DB_HOST')
DB_USER = os.environ.get('DB_USER')
DB_PASSWORD = os.environ.get('DB_PASSWORD')
DB_NAME = os.environ.get('DB_NAME')
STRIPE_SECRET_KEY = os.environ.get('STRIPE_SECRET_KEY')
STRIPE_WEBHOOK_SECRET = os.environ.get('STRIPE_WEBHOOK_SECRET') # IMPORTANT for security

# --- Database Connection ---
def get_db_connection():
    try:
        return pymysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASSWORD, db=DB_NAME, cursorclass=pymysql.cursors.DictCursor)
    except pymysql.MySQLError as e:
        print(f"ERROR: Could not connect to MySQL instance. {e}")
        raise e

# --- Main Handler ---
def lambda_handler(event, context):
    stripe.api_key = STRIPE_SECRET_KEY
    payload = event['body']
    sig_header = event['headers']['stripe-signature']
    
    try:
        stripe_event = stripe.Webhook.construct_event(
            payload, sig_header, STRIPE_WEBHOOK_SECRET
        )
    except ValueError as e:
        # Invalid payload
        return {'statusCode': 400, 'body': json.dumps({'error': str(e)})}
    except stripe.error.SignatureVerificationError as e:
        # Invalid signature
        return {'statusCode': 400, 'body': json.dumps({'error': str(e)})}

    # --- Handle the event ---
    event_type = stripe_event['type']
    payment_intent = stripe_event['data']['object']
    
    if event_type.startswith('payment_intent.'):
        purchase_id = payment_intent.get('metadata', {}).get('purchase_id')
        if not purchase_id:
            print("ERROR: purchase_id not found in PaymentIntent metadata.")
            return {'statusCode': 400, 'body': 'Missing purchase_id'}

        status_map = {
            'payment_intent.succeeded': 'COMPLETE',
            'payment_intent.processing': 'PROCESSING',
            'payment_intent.payment_failed': 'DECLINED',
            'payment_intent.canceled': 'CANCELLED'
        }
        
        new_status = status_map.get(event_type)
        if not new_status:
            print(f"Unhandled event type {event_type}")
            return {'statusCode': 200, 'body': 'Unhandled event type'}

        messages = {}
        if new_status == 'DECLINED':
            messages['stripe_error'] = payment_intent.get('last_payment_error', {}).get('message')

        connection = get_db_connection()
        cursor = connection.cursor()
        try:
            sql = "UPDATE purchase SET status = %s, messages = %s, updatedDt = %s WHERE purchaseId = %s"
            cursor.execute(sql, (new_status, json.dumps(messages) if messages else None, datetime.utcnow(), purchase_id))
            connection.commit()
            print(f"Updated purchase {purchase_id} to status {new_status}")

            # If complete, trigger the finalization process
            if new_status == 'COMPLETE':
                # In a real-world scenario, you would invoke the finalize-purchase Lambda here
                # Example: boto3.client('lambda').invoke(...)
                print(f"TODO: Invoke finalize-purchase Lambda for purchaseId {purchase_id}")

        except Exception as e:
            connection.rollback()
            print(f"Database error: {e}")
            return {'statusCode': 500, 'body': 'Database update failed'}
        finally:
            cursor.close()
            connection.close()

    return {'statusCode': 200, 'body': json.dumps({'status': 'success'})}

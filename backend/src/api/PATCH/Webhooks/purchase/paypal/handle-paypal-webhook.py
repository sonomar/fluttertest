import json
import os
import requests
import pymysql
from datetime import datetime

# --- Environment Variables ---
DB_HOST = os.environ.get('DB_HOST')
# ... (other DB vars)
PAYPAL_CLIENT_ID = os.environ.get('PAYPAL_CLIENT_ID')
PAYPAL_CLIENT_SECRET = os.environ.get('PAYPAL_CLIENT_SECRET')
PAYPAL_WEBHOOK_ID = os.environ.get('PAYPAL_WEBHOOK_ID')
PAYPAL_API_BASE = 'https://api-m.sandbox.paypal.com'

# --- Database Connection ---
# ... (same as before)

# --- PayPal Auth ---
# ... (same as before)

# --- Main Handler ---
def lambda_handler(event, context):
    headers = event['headers']
    body = json.loads(event['body'])
    
    # 1. Verify the webhook signature for security
    try:
        access_token = get_paypal_access_token()
        auth_headers = {'Content-Type': 'application/json', 'Authorization': f'Bearer {access_token}'}
        
        verification_payload = {
            "transmission_id": headers.get('paypal-transmission-id'),
            "transmission_time": headers.get('paypal-transmission-time'),
            "cert_url": headers.get('paypal-cert-url'),
            "auth_algo": headers.get('paypal-auth-algo'),
            "transmission_sig": headers.get('paypal-transmission-sig'),
            "webhook_id": PAYPAL_WEBHOOK_ID,
            "webhook_event": body
        }
        
        response = requests.post(f'{PAYPAL_API_BASE}/v1/notifications/verify-webhook-signature', headers=auth_headers, json=verification_payload)
        if response.json().get('verification_status') != 'SUCCESS':
            raise Exception("Webhook verification failed.")
            
    except Exception as e:
        print(f"Webhook verification error: {e}")
        return {'statusCode': 401, 'body': 'Unauthorized'}

    # 2. Process the event
    event_type = body.get('event_type')
    resource = body.get('resource', {})

    if event_type == 'CHECKOUT.ORDER.APPROVED':
        order_id = resource.get('id')
        purchase_id = resource.get('purchase_units', [{}])[0].get('custom_id')

        if not order_id or not purchase_id:
            return {'statusCode': 400, 'body': 'Missing order or purchase ID.'}
            
        # 3. Capture the payment
        capture_url = f"{PAYPAL_API_BASE}/v2/checkout/orders/{order_id}/capture"
        capture_response = requests.post(capture_url, headers=auth_headers, json={})
        
        if capture_response.status_code in [200, 201]:
            # 4. Update purchase status to COMPLETE
            connection = get_db_connection()
            cursor = connection.cursor()
            try:
                cursor.execute("UPDATE purchase SET status = 'COMPLETE', updatedDt = %s WHERE purchaseId = %s", (datetime.utcnow(), purchase_id))
                connection.commit()
                # TODO: Invoke finalize-purchase Lambda
                print(f"Successfully captured and updated purchase {purchase_id}")
            finally:
                cursor.close()
                connection.close()
        else:
            print(f"Failed to capture payment for order {order_id}. Response: {capture_response.text}")
            # TODO: Update purchase status to ERROR with details

    return {'statusCode': 200, 'body': 'Webhook processed.'}

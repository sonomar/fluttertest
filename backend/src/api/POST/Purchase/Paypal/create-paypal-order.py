import json
import os
import requests
import pymysql
from datetime import datetime

# --- Environment Variables ---
DB_HOST = os.environ.get('DB_HOST')
DB_USER = os.environ.get('DB_USER')
DB_PASSWORD = os.environ.get('DB_PASSWORD')
DB_NAME = os.environ.get('DB_NAME')
PAYPAL_CLIENT_ID = os.environ.get('PAYPAL_CLIENT_ID')
PAYPAL_CLIENT_SECRET = os.environ.get('PAYPAL_CLIENT_SECRET')
PAYPAL_API_BASE = 'https://api-m.sandbox.paypal.com' # Use 'https://api-m.paypal.com' for production

# --- Database Connection ---
def get_db_connection():
    # ... (same as your Stripe Lambda)
    pass

# --- PayPal Auth ---
def get_paypal_access_token():
    auth = (PAYPAL_CLIENT_ID, PAYPAL_CLIENT_SECRET)
    headers = {'Accept': 'application/json', 'Accept-Language': 'en_US'}
    data = {'grant_type': 'client_credentials'}
    response = requests.post(f'{PAYPAL_API_BASE}/v1/oauth2/token', headers=headers, data=data, auth=auth)
    response.raise_for_status()
    return response.json()['access_token']

# --- Main Handler ---
def lambda_handler(event, context):
    body = json.loads(event.get('body', '{}'))
    cart = body.get('cart', [])
    user_id = body.get('userId')

    if not cart:
        return {'statusCode': 400, 'body': json.dumps({'message': 'Cart is empty.'})}

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        # 1. Create 'purchase' record
        now = datetime.utcnow()
        cursor.execute(
            "INSERT INTO purchase (userId, currency, type, status, createdDt, updatedDt) VALUES (%s, %s, %s, %s, %s, %s)",
            (user_id, 'PAYPAL', 'CART', 'NOTSTARTED', now, now)
        )
        purchase_id = cursor.lastrowid

        # 2. Create 'purchaseCollectible' records
        # ... (same as your Stripe Lambda)
        
        # 3. Create PayPal Order
        access_token = get_paypal_access_token()
        headers = {'Content-Type': 'application/json', 'Authorization': f'Bearer {access_token}'}
        
        total_value = sum(item['price'] * item['quantity'] for item in cart)
        
        payload = {
            "intent": "CAPTURE",
            "purchase_units": [{
                "amount": {
                    "currency_code": "EUR",
                    "value": f"{total_value:.2f}"
                },
                "custom_id": str(purchase_id) # Link our DB record to the PayPal order
            }],
            "application_context": {
                "return_url": "https://<your-domain>/payment/success",
                "cancel_url": "https://<your-domain>/payment/cancel",
                "brand_name": "Ubunation"
            }
        }

        response = requests.post(f'{PAYPAL_API_BASE}/v2/checkout/orders', headers=headers, json=payload)
        response.raise_for_status()
        order_data = response.json()

        # Find the approval link
        approve_link = next((link['href'] for link in order_data['links'] if link['rel'] == 'approve'), None)
        if not approve_link:
            raise Exception("Approve link not found in PayPal response.")

        connection.commit()

        return {
            'statusCode': 200,
            'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'approveUrl': approve_link})
        }

    except Exception as e:
        connection.rollback()
        print(f"An error occurred: {e}")
        return {'statusCode': 500, 'body': json.dumps({'message': 'Internal server error.'})}
    finally:
        cursor.close()
        connection.close()

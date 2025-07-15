import json
import os
import stripe
import pymysql
from datetime import datetime

# --- Environment Variables ---
# Make sure to set these in your Lambda configuration
DB_HOST = os.environ.get('DB_HOST')
DB_USER = os.environ.get('DB_USER')
DB_PASSWORD = os.environ.get('DB_PASSWORD')
DB_NAME = os.environ.get('DB_NAME')
STRIPE_SECRET_KEY = os.environ.get('STRIPE_SECRET_KEY')

# --- Database Connection ---
def get_db_connection():
    try:
        return pymysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASSWORD, db=DB_NAME, cursorclass=pymysql.cursors.DictCursor)
    except pymysql.MySQLError as e:
        print("ERROR: Unexpected error: Could not connect to MySQL instance.")
        print(e)
        raise e

# --- Main Handler ---
def lambda_handler(event, context):
    print("Received event:", json.dumps(event))
    
    stripe.api_key = STRIPE_SECRET_KEY
    body = json.loads(event.get('body', '{}'))
    cart = body.get('cart', [])
    user_id = body.get('userId') # Can be None if user is not logged in

    if not cart:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Cart cannot be empty.'})
        }

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        # 1. Calculate total amount
        # Price is in cents for Stripe (e.g., 9.99 EUR -> 999)
        total_amount = sum(int(item['price'] * 100) * item['quantity'] for item in cart)

        # 2. Create a 'purchase' record in the database
        purchase_sql = """
            INSERT INTO purchase (userId, currency, type, status, createdDt, updatedDt)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        now = datetime.utcnow()
        cursor.execute(purchase_sql, (user_id, 'STRIPE', 'CART', 'NOTSTARTED', now, now))
        purchase_id = cursor.lastrowid
        print(f"Created purchase record with ID: {purchase_id}")

        # 3. Create 'purchaseCollectible' records for each item
        pc_sql = "INSERT INTO purchaseCollectible (purchaseId, collectibleId) VALUES (%s, %s)"
        collectibles_to_insert = []
        for item in cart:
            for _ in range(item['quantity']):
                collectibles_to_insert.append((purchase_id, item['collectibleId']))
        
        cursor.executemany(pc_sql, collectibles_to_insert)
        print(f"Inserted {len(collectibles_to_insert)} purchaseCollectible records.")

        # 4. Create a Stripe PaymentIntent
        payment_intent = stripe.PaymentIntent.create(
            amount=total_amount,
            currency='eur',
            automatic_payment_methods={'enabled': True},
            metadata={
                'purchase_id': purchase_id,
                'user_id': user_id or 'guest'
            }
        )
        print(f"Created Stripe PaymentIntent: {payment_intent.id}")

        # 5. Commit database changes
        connection.commit()

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*', # Adjust for production
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST,OPTIONS'
            },
            'body': json.dumps({
                'clientSecret': payment_intent.client_secret,
                'purchaseId': purchase_id
            })
        }

    except Exception as e:
        connection.rollback()
        print(f"An error occurred: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal server error.'})
        }
    finally:
        cursor.close()
        connection.close()


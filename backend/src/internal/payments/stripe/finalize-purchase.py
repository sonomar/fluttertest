import json
import os
import pymysql
import boto3
from datetime import datetime
from botocore.exceptions import ClientError

# --- Environment Variables ---
DB_HOST = os.environ.get('DB_HOST')
DB_USER = os.environ.get('DB_USER')
DB_PASSWORD = os.environ.get('DB_PASSWORD')
DB_NAME = os.environ.get('DB_NAME')
SES_SENDER_EMAIL = os.environ.get('SES_SENDER_EMAIL')
SES_REGION = os.environ.get('SES_REGION', 'eu-central-1')

# --- Database Connection ---
def get_db_connection():
    try:
        return pymysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASSWORD, db=DB_NAME, cursorclass=pymysql.cursors.DictCursor)
    except pymysql.MySQLError as e:
        print(f"ERROR: Could not connect to MySQL instance. {e}")
        raise e

# --- Main Handler ---
def lambda_handler(event, context):
    # This Lambda would be invoked by the webhook handler upon success
    # The event payload would contain the purchase_id
    purchase_id = event.get('purchase_id')
    if not purchase_id:
        print("ERROR: purchase_id not provided in event.")
        return {'statusCode': 400}

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        # 1. Get purchase details and user email
        cursor.execute("""
            SELECT p.userId, u.email, p.createdDt 
            FROM purchase p
            JOIN user u ON p.userId = u.userId
            WHERE p.purchaseId = %s
        """, (purchase_id,))
        purchase_info = cursor.fetchone()
        
        if not purchase_info or not purchase_info.get('userId'):
            print(f"Purchase {purchase_id} has no associated user. Skipping userCollectible creation and email.")
            return {'statusCode': 200}
        
        user_id = purchase_info['userId']
        user_email = purchase_info['email']

        # 2. Get all collectibles associated with this purchase
        cursor.execute("SELECT collectibleId FROM purchaseCollectible WHERE purchaseId = %s", (purchase_id,))
        collectibles = cursor.fetchall()

        # 3. Create userCollectible records
        uc_sql = "INSERT INTO userCollectible (ownerId, collectibleId, mint) VALUES (%s, %s, %s)"
        collectibles_to_insert = [(user_id, c['collectibleId'], f"purchase-{purchase_id}") for c in collectibles]
        
        if collectibles_to_insert:
            cursor.executemany(uc_sql, collectibles_to_insert)
            print(f"Created {len(collectibles_to_insert)} userCollectible records for user {user_id}.")

        # 4. Send confirmation email via SES
        send_confirmation_email(user_email, purchase_id, collectibles)

        connection.commit()
        return {'statusCode': 200, 'body': 'Finalization complete.'}

    except Exception as e:
        connection.rollback()
        print(f"An error occurred during finalization: {e}")
        return {'statusCode': 500}
    finally:
        cursor.close()
        connection.close()

def send_confirmation_email(recipient, purchase_id, items):
    ses_client = boto3.client('ses', region_name=SES_REGION)
    
    # Simple email body generation
    item_list_html = "<ul>"
    for item in items:
        # In a real app, you'd join with the collectibles table to get names and prices
        item_list_html += f"<li>Collectible ID: {item['collectibleId']} - Price: €9.99</li>"
    item_list_html += "</ul>"
    
    total_price = len(items) * 9.99
    # Add tax calculation here if needed
    grand_total = total_price

    BODY_HTML = f"""
    <html>
    <head></head>
    <body>
      <h1>Thank you for your purchase!</h1>
      <p>Your purchase with ID {purchase_id} is complete.</p>
      <h3>Purchase Details:</h3>
      {item_list_html}
      <p><strong>Total:</strong> €{grand_total:.2f}</p>
    </body>
    </html>
    """
    
    try:
        response = ses_client.send_email(
            Destination={'ToAddresses': [recipient]},
            Message={
                'Body': {'Html': {'Charset': 'UTF-8', 'Data': BODY_HTML}},
                'Subject': {'Charset': 'UTF-8', 'Data': f'Your Ubunation Purchase Confirmation ({purchase_id})'},
            },
            Source=SES_SENDER_EMAIL,
        )
    except ClientError as e:
        print("Email sending failed:", e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:", response['MessageId'])


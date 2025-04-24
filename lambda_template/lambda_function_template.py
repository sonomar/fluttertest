import pymysql
import boto3
import json
import os

# Use this code snippet in your app.
# If you need more information about configurations
# or implementing the sample code, visit the AWS docs:
# https://aws.amazon.com/developer/language/python/

#from botocore.exceptions import ClientError
 

def get_secrets():
    secrets_client = boto3.client('secretsmanager')
    secret_name = os.environ.get('secret_key')

    try:
        secret_response = secrets_client.get_secret_value(SecretId=secret_name)
        secret_string = secret_response.get('SecretString')
        parameters = json.loads(secret_string)
        return parameters
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        return f"Error retrieving secret: {e}"  # Or handle the error appropriately

def get_connectionENV():
    parameters = get_secrets()
    try:
        conn =pymysql.connect(
            host=parameters['DB_HOST'],
            password= parameters['DB_PASSWORD'],
            user= parameters['DB_USER'],
            db= parameters['DB_NAME'],
            connect_timeout=5,
            #cursorclass=pymysql.cursors.DictCursor
        )
        return conn

    except pymysql.MySQLError as e:
        logger.error("ERROR: Unexpected error: Could not connect to MySQL instance.")
        logger.error(e)
        sys.exit(1)
        return f"Error retrieving secret: {e}"
    

def lambda_handler(event, context):
    user_id = json.loads(event.get('body'))["UserId"]
    if not user_id:
        return {'statusCode': 400, 'body': 'UserId not found'}
    
    connection = get_connectionENV()
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM User WHERE UserId = %s", (user_id,))
        user = cursor.fetchone()
    
    return {'statusCode': 200, 'body': f"{user}"}

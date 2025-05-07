import json
import boto3
import os
import pymysql
import logging
import sys

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

def get_connection():
    if os.environ.get('ENV') == 'production':
        parameters = get_secrets()

        logging.basicConfig(level=logging.INFO)
        logger = logging.getLogger(__name__) 

        try:
            conn =pymysql.connect(
                host=parameters['DB_HOST'],
                password= parameters['DB_PASSWORD'],
                user= parameters['DB_USER'],
                db= parameters['DB_NAME'],
                connect_timeout=5,
            )
            return conn

        except pymysql.MySQLError as e:
            logger.error("ERROR: Unexpected error: Could not connect to MySQL instance.")
            logger.error(e)
            sys.exit(1)
            return f"Error retrieving secret: {e}"
    else:
        from dotenv import load_dotenv
        load_dotenv() 
        # Local: Use environment variables
        return pymysql.connect(
            host=os.environ.get('DB_HOST'),
            user=os.environ.get('DB_USER'),
            password=os.environ.get('DB_PASSWORD'),
            db=os.environ.get('DB_NAME'),
            connect_timeout=5
        )

def split_string(string):
  """Splits a string of the format '/prefix/suffix' into 'suffix'."""

  parts = string.split('/')
  return '/' + parts[-1]

def extractData(event):
    """
    Extracts the 'CollectibleId' from the 'body' of the event.
    
    Args:
        event (dict): The event dictionary containing the body.
        
    Returns:
        collectible_id (str/int/None): The 'CollectibleId' if present, or None.
    """
    body = event.get('body')
    queryStringParameters = event.get('queryStringParameters')
    data = None
    if body:
        try:
            data = json.loads(body)
        except json.JSONDecodeError:
            print("Invalid JSON in body")
    elif queryStringParameters:
        try:
            data = queryStringParameters
        except json.JSONDecodeError:
            print("Invalid JSON in body")
    else:
        print("Body not found in the event.")
    
    return data
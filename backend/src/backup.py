import pymysql
import boto3
import json
import os

# Use this code snippet in your app.
# If you need more information about configurations
# or implementing the sample code, visit the AWS docs:
# https://aws.amazon.com/developer/language/python/

#from botocore.exceptions import ClientError

GET_RAW_PATH_getCollectibleByCollectibleId = '/getCollectibleByCollectibleId'
GET_RAW_PATH_getAllCollectibles = '/getAllCollectibles'
GET_RAW_PATH_getCollectiblesByCategoryId = '/getCollectiblesByCategoryId'
GET_RAW_PATH_getCollectiblesByProjectId = '/getCollectiblesByProjectId'
GET_RAW_PATH_getUserByUserId = '/getUserByUserId'
GET_RAW_PATH_getProjectByProjectId = '/getProjectByProjectId'
GET_RAW_PATH_getUserCollectiblesByUserId = '/getUserCollectiblesByUserId'
CREATE_RAW_PATH_addUser = '/addUser'
UPDATE_RAW_PATH_updateUserByUserId = '/updateUserByUserId'
UPDATE_RAW_PATH_updateUserByUserName = '/updateUserByUsername'
HTTP_METHOD_GET = 'GET'
HTTP_METHOD_POST = 'POST' 
HTTP_METHOD_PATCH = 'PATCH' 
 

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
    if body:
        try:
            data = json.loads(body)
        except json.JSONDecodeError:
            print("Invalid JSON in body")
    elif queryStringParameters:
        try:
            data = json.loads(queryStringParameters)
        except json.JSONDecodeError:
            print("Invalid JSON in body")
    else:
        print("Body not found in the event.")
    
    return None

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


def addUser(event):
    username = json.loads(event.get('body'))["username"]
    email = json.loads(event.get('body'))["Email"]
    deviceId = json.loads(event.get('body'))["deviceId"]
    UserType = json.loads(event.get('body'))["UserType"]
    if not username:
        return {'statusCode': 400, 'body': 'username is required'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        sql = "INSERT INTO User (username, Email, deviceId, CreatedDt, UpdatedDt, UserType, Active) VALUES (%s, %s, %s, NOW(), NOW(), %s, TRUE)"
        cursor.execute(sql, (username, email, deviceId, UserType))
        connection.commit()
    
    return {'statusCode': 201, 'body': 'User created successfully'}

def getAllCollectibles(event):
    connection = get_connection()
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM Collectible WHERE Active = TRUE")
        collectibles = cursor.fetchall()
    
    return {'statusCode': 200, 'body': f"{collectibles}"}

def getCollectiblesByCategoryId(event):
    project_id = json.loads(event.get('body'))["CategoryId"]
    if not project_id:
        return {'statusCode': 400, 'body': 'CategoryId is required'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        sql = "SELECT * FROM Collectible WHERE CategoryId = %s AND Active = TRUE"
        cursor.execute(sql, (project_id))
        collectibles = cursor.fetchall()
    
    return {'statusCode': 200, 'body': f"{collectibles}"}

def getCollectiblesByProjectId(event):
    project_id = json.loads(event.get('body'))["ProjectId"]
    if not project_id:
        return {'statusCode': 400, 'body': 'projectId is required'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        sql = "SELECT * FROM Collectible WHERE ProjectId = %s AND Active = TRUE"
        cursor.execute(sql, (project_id))
        collectibles = cursor.fetchall()
    
    return {'statusCode': 200, 'body': f"{collectibles}"}

def getCollectibleByCollectibleId(event):
    data = extractData(event)
    collectible_id = data["CollectibleId"]
    if not collectible_id:
        return {'statusCode': 400, 'body': 'collectibleId is required'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        sql = "SELECT * FROM Collectible WHERE CollectibleId = %s AND Active = TRUE"
        cursor.execute(sql, (collectible_id))
        collectible = cursor.fetchone()
    
    return {'statusCode': 200, 'body': f"{collectible}"}

def getUserByUserId(event):
    user_id = json.loads(event.get('body'))["UserId"]
    if not user_id:
        return {'statusCode': 400, 'body': 'UserId not found'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM User WHERE UserId = %s", (user_id))
        user = cursor.fetchone()
    
    return {'statusCode': 200, 'body': f"{user}"}

def updateUserByUserId(event):
    user_id = json.loads(event.get('body'))["UserId"]#event.get('userId')
    username = json.loads(event.get('body'))["username"]#event.get('username')
    if not user_id or not username:
        return {'statusCode': 400, 'body': 'userId and username are required'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        sql = "UPDATE User SET username = %s, UpdatedDt = NOW() WHERE UserId = %s"
        cursor.execute(sql, (username, user_id))
        connection.commit()
    
    return {'statusCode': 200, 'body': 'User updated successfully'}

def updateUserByUsername(event):
    usernameNew = json.loads(event.get('body'))["usernameNew"]
    username = json.loads(event.get('body'))["username"]
    if not usernameNew or not username:
        return {'statusCode': 400, 'body': 'userId and username are required'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        sql = "UPDATE User SET username = %s, UpdatedDt = NOW() WHERE username = %s"
        cursor.execute(sql, (usernameNew, username))
        connection.commit()
    
    return {'statusCode': 200, 'body': 'User updated successfully'}

def getProjectByProjectId(event):
    project_id = json.loads(event.get('body'))["ProjectId"]
    if not project_id:
        return {'statusCode': 400, 'body': 'ProjectId not found'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM Project WHERE ProjectId = %s", (project_id))
        project = cursor.fetchone()
    
    return {'statusCode': 200, 'body': f"{project}"}

def getUserCollectiblesByUserId(event):
    user_id = json.loads(event.get('body'))["UserId"]
    if not user_id:
        return {'statusCode': 400, 'body': 'UserId not found'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM UserCollectible WHERE OwnerId = %s", (user_id))
        userCollectibles = cursor.fetchone()
    
    return {'statusCode': 200, 'body': f"{userCollectibles}"}


def lambda_handler(event, context):
    http_method = event.get('requestContext')["http"]["method"]
    raw_path = split_string(f"{event['rawPath']}")
    returnString = 'Invalid Function Call'

    if raw_path == GET_RAW_PATH_getAllCollectibles and http_method == HTTP_METHOD_GET:
        returnString = getAllCollectibles(event)
    
    elif raw_path == GET_RAW_PATH_getCollectibleByCollectibleId and http_method == HTTP_METHOD_GET:
        returnString = getCollectibleByCollectibleId(event)
    
    elif raw_path == GET_RAW_PATH_getCollectiblesByProjectId and http_method == HTTP_METHOD_GET:
        returnString = getCollectiblesByProjectId(event)

    elif raw_path == GET_RAW_PATH_getCollectiblesByCategoryId and http_method == HTTP_METHOD_GET:
        returnString = getCollectiblesByCategoryId(event)
    
    elif raw_path == GET_RAW_PATH_getUserByUserId and http_method == HTTP_METHOD_GET:
        returnString = getUserByUserId(event)

    elif raw_path == CREATE_RAW_PATH_addUser and http_method == HTTP_METHOD_POST:
        returnString = addUser(event)

    elif raw_path == UPDATE_RAW_PATH_updateUserByUserId and http_method == HTTP_METHOD_PATCH:
        returnString = updateUserByUserId(event)

    elif raw_path == UPDATE_RAW_PATH_updateUserByUserName and http_method == HTTP_METHOD_PATCH:
        returnString = updateUserByUsername(event)

    elif raw_path == GET_RAW_PATH_getProjectByProjectId and http_method == HTTP_METHOD_GET:
        returnString = getProjectByProjectId(event)

    elif raw_path == GET_RAW_PATH_getUserCollectiblesByUserId and http_method == HTTP_METHOD_GET:
        returnString = getUserCollectiblesByUserId(event)

    #return {'statusCode': 200, 'body': f"{event.get('requestContext')["http"]["method"]}"}
    return returnString

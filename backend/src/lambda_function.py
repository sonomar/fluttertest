from api.routeCheckAll import http_router_all
# Import the database session dependency
from database.db import get_db # Adjust import path if necessary


# Manually get the db session
db_gen = get_db()
db = next(db_gen)


# Use this code snippet in your app.
# If you need more information about configurations
# or implementing the sample code, visit the AWS docs:
# https://aws.amazon.com/developer/language/python/

#from botocore.exceptions import ClientError

def lambda_handler(event, context):
    
    returnString = 'Invalid Call Parameters'
    event['db_session'] = db
    returnString = http_router_all(event)


    #return {'statusCode': 200, 'body': f"{event.get('requestContext')["http"]["method"]}"}
    return returnString

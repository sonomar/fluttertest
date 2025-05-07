from api.routeCheckAll import http_router_all

# Use this code snippet in your app.
# If you need more information about configurations
# or implementing the sample code, visit the AWS docs:
# https://aws.amazon.com/developer/language/python/

#from botocore.exceptions import ClientError

def lambda_handler(event, context):
    
    returnString = 'Invalid Call Parameters'
    returnString = http_router_all(event)


    #return {'statusCode': 200, 'body': f"{event.get('requestContext')["http"]["method"]}"}
    return returnString

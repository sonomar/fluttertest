from tools.prod.prodTools import extractData
from database.schema.POST.DistributionCodeUser.distributionCodeUser_schema import DistributionCodeUserCreate
import database.CRUD.POST.DistributionCodeUser.post_DistributionCodeUser_CRUD_functions as crudFunctions

def createDistributionCodeUser(event):
    data = extractData(event)
    if not data:
        return {'statusCode': 400, 'body': 'Request body is missing'}

    # Basic validation for required fields
    required_fields = ["userId", "distributionCodeId", "redeemed"]
    if not all(field in data for field in required_fields):
        return {
            "statusCode": 400,
            "body": "Missing one or more required fields: userId, distributionCodeId, redeemed"
        }
        
    distribution_code_user = DistributionCodeUserCreate(**data)
    
    return crudFunctions.createDistributionCodeUser(distribution_code_user=distribution_code_user, db=event["db_session"])
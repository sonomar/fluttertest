from tools.prod.prodTools import extractData
from database.schema.POST.DistributionCode.distributionCode_schema import DistributionCodeCreate
import database.CRUD.POST.DistributionCode.post_DistributionCode_CRUD_functions as crudFunctions

def createDistributionCode(event):
    data = extractData(event)
    if not data:
        return {'statusCode': 400, 'body': 'Request body is missing'}

    # Basic validation for required fields
    required_fields = ["distributionId", "code", "isMultiUse"]
    if not all(field in data for field in required_fields):
        return {
            "statusCode": 400,
            "body": "Missing one or more required fields: distributionId, code, isMultiUse"
        }
        
    distribution_code = DistributionCodeCreate(**data)
    
    return crudFunctions.createDistributionCode(distribution_code=distribution_code, db=event["db_session"])
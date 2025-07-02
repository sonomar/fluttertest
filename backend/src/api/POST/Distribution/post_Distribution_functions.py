from tools.prod.prodTools import extractData
from database.schema.POST.Distribution.distribution_schema import DistributionCreate
import database.CRUD.POST.Distribution.post_Distribution_CRUD_functions as crudFunctions

def createDistribution(event):
    data = extractData(event)
    if not data:
        return {'statusCode': 400, 'body': 'Request body is missing'}

    # Basic validation for required fields
    required_fields = ["projectId", "name", "type", "isTimed", "isLimited", "isNewUserReward", "isRandom", "startDate", "endDate"]
    if not all(field in data for field in required_fields):
        return {
            "statusCode": 400,
            "body": "Missing one or more required fields: projectId, name, type, isTimed, isLimited, isNewUserReward, isRandom, startDate, endDate"
        }

    distribution = DistributionCreate(**data)
    
    return crudFunctions.createDistribution(distribution=distribution, db=event["db_session"])
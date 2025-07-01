from tools.prod.prodTools import extractData
from database.schema.POST.DistributionCollectible.distributionCollectible_schema import DistributionCollectibleCreate
import database.CRUD.POST.DistributionCollectible.post_DistributionCollectible_CRUD_functions as crudFunctions

def createDistributionCollectible(event):
    data = extractData(event)
    if not data:
        return {'statusCode': 400, 'body': 'Request body is missing'}

    # Basic validation for required fields
    required_fields = ["collectibleId", "distributionId"]
    if not all(field in data for field in required_fields):
        return {
            "statusCode": 400,
            "body": "Missing one or more required fields: collectibleId, distributionId"
        }
        
    distribution_collectible = DistributionCollectibleCreate(**data)
    
    return crudFunctions.createDistributionCollectible(distribution_collectible=distribution_collectible, db=event["db_session"])
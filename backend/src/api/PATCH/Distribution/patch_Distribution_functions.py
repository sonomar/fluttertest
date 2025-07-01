from tools.prod.prodTools import extractData
import database.CRUD.PATCH.Distribution.patch_Distribution_CRUD_functions as crudFunctions
from database.schema.PATCH.Distribution.distribution_schema import DistributionUpdate

def updateDistributionByDistributionId(event):
    data = extractData(event)
    if not data or "distributionId" not in data:
        return {'statusCode': 400, 'body': 'distributionId is required'}
    
    distribution_id = data["distributionId"]
    distribution = DistributionUpdate(**data)
    
    return crudFunctions.updateDistributionByDistributionId(distributionId=distribution_id, distribution=distribution, db=event['db_session'])
from tools.prod.prodTools import extractData
import database.CRUD.PATCH.DistributionCollectible.patch_DistributionCollectible_CRUD_functions as crudFunctions
from database.schema.PATCH.DistributionCollectible.distributionCollectible_schema import DistributionCollectibleUpdate

def updateDistributionCollectibleByDistributionCollectibleId(event):
    data = extractData(event)
    if not data or "distributionCollectibleId" not in data:
        return {'statusCode': 400, 'body': 'distributionCollectibleId is required'}
    
    distribution_collectible_id = data["distributionCollectibleId"]
    distribution_collectible = DistributionCollectibleUpdate(**data)
    
    return crudFunctions.updateDistributionCollectibleByDistributionCollectibleId(distributionCollectibleId=distribution_collectible_id, distribution_collectible=distribution_collectible, db=event['db_session'])
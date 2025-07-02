from tools.prod.prodTools import extractData
import database.CRUD.DELETE.DistributionCollectible.delete_DistributionCollectible_CRUD_functions as crudFunctions

def deleteDistributionCollectibleByDistributionCollectibleId(event):
    data = extractData(event)
    if not data or "distributionCollectibleId" not in data:
        return {'statusCode': 400, 'body': 'distributionCollectibleId is required'}
    
    distribution_collectible_id = data["distributionCollectibleId"]
    
    return crudFunctions.deleteDistributionCollectibleByDistributionCollectibleId(distributionCollectibleId=distribution_collectible_id, db=event['db_session'])
from tools.prod.prodTools import extractData
import database.CRUD.GET.DistributionCollectible.get_DistributionCollectible_CRUD_functions as crudFunctions

def getDistributionCollectibleByDistributionCollectibleId(event):
    data = extractData(event)
    if not data or "distributionCollectibleId" not in data:
        return {'statusCode': 400, 'body': 'distributionCollectibleId is required'}
    
    distribution_collectible_id = data["distributionCollectibleId"]
    return crudFunctions.getDistributionCollectibleByDistributionCollectibleId(distributionCollectibleId=distribution_collectible_id, db=event['db_session'])

def getAllDistributionCollectibles(event):
    data = extractData(event)
    skip = 0
    limit = 100
    if data:
        skip = data.get("skip", 0)
        limit = data.get("limit", 100)
        
    return crudFunctions.getAllDistributionCollectibles(skip=skip, limit=limit, db=event['db_session'])

def getDistributionCollectiblesByCollectibleId(event):
    data = extractData(event)
    if not data or "collectibleId" not in data:
        return {'statusCode': 400, 'body': 'collectibleId is required'}
        
    collectible_id = data["collectibleId"]
    return crudFunctions.getDistributionCollectiblesByCollectibleId(collectibleId=collectible_id, db=event['db_session'])
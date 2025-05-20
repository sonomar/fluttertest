# database/CRUD/GET/Collectible/get_Collectible_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.Collectible.get_Collectible_CRUD_functions as crudFunctions

def getCollectibleByCollectibleId(event):
    """
    Retrieves a collectible by its collectibleId.
    Requires 'collectibleId' in the request data.
    """
    data = extractData(event)
    if not data or "collectibleId" not in data:
        return {'statusCode': 400, 'body': 'collectibleId is required'}

    collectible_id = data["collectibleId"]
    return crudFunctions.getCollectibleByCollectibleId(collectibleId=collectible_id, db=event['db_session'])

def getCollectibleByName(event):
    """
    Retrieves collectibles by their name.
    Requires 'name' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "name" not in data:
        return {'statusCode': 400, 'body': 'name is required'}

    name = data["name"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCollectibleByName(name=name, skip=skip, limit=limit, db=event['db_session'])

def getCollectiblesByLabel(event):
    """
    Retrieves collectibles by their label.
    Requires 'label' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "label" not in data:
        return {'statusCode': 400, 'body': 'label is required'}

    label = data["label"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCollectiblesByLabel(label=label, skip=skip, limit=limit, db=event['db_session'])

def getCollectiblesBySponsor(event):
    """
    Retrieves collectibles by sponsor ID.
    Requires 'sponsorId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "sponsorId" not in data:
        return {'statusCode': 400, 'body': 'sponsorId is required'}

    sponsor_id = data["sponsorId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCollectiblesBySponsor(sponsorId=sponsor_id, skip=skip, limit=limit, db=event['db_session'])

def getCollectiblesByCollection(event):
    """
    Retrieves collectibles by collection ID.
    Requires 'collectionId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "collectionId" not in data:
        return {'statusCode': 400, 'body': 'collectionId is required'}

    collection_id = data["collectionId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCollectiblesByCollection(collectionId=collection_id, skip=skip, limit=limit, db=event['db_session'])

def getCollectiblesByCommunity(event):
    """
    Retrieves collectibles by community ID.
    Requires 'communityId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "communityId" not in data:
        return {'statusCode': 400, 'body': 'communityId is required'}

    community_id = data["communityId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCollectiblesByCommunity(communityId=community_id, skip=skip, limit=limit, db=event['db_session'])


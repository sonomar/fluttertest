# database/CRUD/GET/UserCollectible/get_UserCollectible_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.UserCollectible.get_UserCollectible_CRUD_functions as crudFunctions

def getUserCollectibleByCollectibleIdAndMint(event):
    """
    Retrieves a user collectible by collectible ID and mint number.
    Requires 'collectibleId' and 'mint' in the request data.
    """
    data = extractData(event)
    if not data or "collectibleId" not in data or "mint" not in data:
        return {'statusCode': 400, 'body': 'collectibleId and mint are required'}

    collectible_id = data["collectibleId"]
    mint = data["mint"]
    return crudFunctions.getUserCollectibleByCollectibleIdAndMint(collectibleId=collectible_id, mint=mint, db=event['db_session'])

def getUserCollectiblesByOwnerId(event):
    """
    Retrieves user collectibles by owner ID.
    Requires 'ownerId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "ownerId" not in data:
        return {'statusCode': 400, 'body': 'ownerId is required'}

    owner_id = data["ownerId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getUserCollectiblesByOwnerId(ownerId=owner_id, skip=skip, limit=limit, db=event['db_session'])

def getUserCollectiblesByLastOwned(event):
    """
    Retrieves user collectibles by last transferred date.
    Requires 'lastTransferredDtAfter' timestamp in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "lastTransferredDtAfter" not in data:
        return {'statusCode': 400, 'body': 'lastTransferredDtAfter timestamp is required'}

    last_transferred_dt_after = data["lastTransferredDtAfter"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getUserCollectiblesByLastOwned(lastTransferredDtAfter=last_transferred_dt_after, skip=skip, limit=limit, db=event['db_session'])

def getUserCollectiblesByCollectibleId(event):
    """
    Retrieves user collectibles by collectible ID.
    Requires 'collectibleId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "collectibleId" not in data:
        return {'statusCode': 400, 'body': 'collectibleId is required'}

    collectible_id = data["collectibleId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getUserCollectiblesByCollectibleId(collectibleId=collectible_id, skip=skip, limit=limit, db=event['db_session'])

def getUserCollectibleByUserCollectibleId(event):
    """
    Retrieves user collectibles by collectible ID.
    Requires 'userCollectibleId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "userCollectibleId" not in data:
        return {'statusCode': 400, 'body': 'userCollectibleId is required'}

    userCollectibleId = data["userCollectibleId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getUserCollectiblesByUserCollectibleId(userCollectibleId=userCollectibleId, skip=skip, limit=limit, db=event['db_session'])
# database/CRUD/GET/CollectibleSponsor/get_CollectibleSponsor_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.CollectibleSponsor.get_CollectibleSponsor_CRUD_functions as crudFunctions

def getCollectibleSponsorById(event):
    """
    Retrieves a collectible sponsor record by its collectibleSponsorId.
    Requires 'collectibleSponsorId' in the request data.
    """
    data = extractData(event)
    if not data or "collectibleSponsorId" not in data:
        return {'statusCode': 400, 'body': 'collectibleSponsorId is required'}

    collectible_sponsor_id = data["collectibleSponsorId"]
    return crudFunctions.getCollectibleSponsorById(collectibleSponsorId=collectible_sponsor_id, db=event['db_session'])

def getCollectibleSponsorByCollectibleId(event):
    """
    Retrieves collectible sponsor records by collectible ID.
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

    return crudFunctions.getCollectibleSponsorByCollectibleId(collectibleId=collectible_id, skip=skip, limit=limit, db=event['db_session'])

def getCollectibleSponsorBySponsorId(event):
    """
    Retrieves collectible sponsor records by sponsor ID.
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

    return crudFunctions.getCollectibleSponsorBySponsorId(sponsorId=sponsor_id, skip=skip, limit=limit, db=event['db_session'])
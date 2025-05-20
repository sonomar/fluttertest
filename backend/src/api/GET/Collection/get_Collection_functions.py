# database/CRUD/GET/Collection/get_Collection_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.Collection.get_Collection_CRUD_functions as crudFunctions

def getCollectionByCollectionId(event):
    """
    Retrieves a collection by its collectionId.
    Requires 'collectionId' in the request data.
    """
    data = extractData(event)
    if not data or "collectionId" not in data:
        return {'statusCode': 400, 'body': 'collectionId is required'}

    collection_id = data["collectionId"]
    return crudFunctions.getCollectionByCollectionId(collectionId=collection_id, db=event['db_session'])

def getCollectionByName(event):
    """
    Retrieves collections by their name.
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

    return crudFunctions.getCollectionByName(name=name, skip=skip, limit=limit, db=event['db_session'])


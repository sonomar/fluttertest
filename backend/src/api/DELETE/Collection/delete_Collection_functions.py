from tools.prod.prodTools import extractData
import database.CRUD.DELETE.Collection.delete_Collection_CRUD_functions as crudFunctions


def deleteCollectionByCollectionId(event):
    """
    Deletes a Collection record by collectionId.
    Requires 'collectionId'.
    """
    data = extractData(event)
    if not data or "collectionId" not in data:
        return {'statusCode': 400, 'body': 'collectionId is required'}

    collection_id = data["collectionId"]
    return crudFunctions.deleteCollectionByCollectionId(collectionId=collection_id,db=event['db_session'])
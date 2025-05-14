from tools.prod.prodTools import extractData
import database.CRUD.DELETE.Collectible.delete_Collectible_CRUD_functions as crudFunctions


def deleteCollectibleByCollectibleId(event):
    """
    Deletes a Collectible record by collectibleId.
    Requires 'collectibleId'.
    """
    data = extractData(event)
    if not data or "collectibleId" not in data:
        return {'statusCode': 400, 'body': 'collectibleId is required'}

    collectible_id = data["collectibleId"]
    return crudFunctions.deleteCollectibleByCollectibleId(collectibleId=collectible_id,db=event['db_session'])
from tools.prod.prodTools import extractData
import database.CRUD.DELETE.UserCollectible.delete_UserCollectible_CRUD_functions as crudFunctions



def deleteUserCollectibleByUserCollectibleId(event):
    """
    Deletes a userCollectible record by userCollectibleId.
    Requires 'userCollectibleId'.
    """
    data = extractData(event)
    if not data or "userCollectibleId" not in data:
        return {'statusCode': 400, 'body': 'userCollectibleId is required'}

    userCollectible_id = data["userCollectibleId"]
    return crudFunctions.deleteUserCollectibleByUserCollectibleId(userCollectibleId=userCollectible_id,db=event['db_session'])
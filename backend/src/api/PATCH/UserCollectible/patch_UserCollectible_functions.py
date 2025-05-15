from tools.prod.prodTools import extractData
import database.CRUD.PATCH.UserCollectible.patch_UserCollectible_CRUD_functions as crudFunctions
from database.schema.PATCH.UserCollectible.userCollectible_schema import UserCollectibleUpdate
import datetime

def UserCollectibleDataCheck(userCollectible: UserCollectibleUpdate, data: any):
    if "ownerId" in data:
        userCollectible.ownerId = data["ownerId"]
    if "collectibleId" in data:
        userCollectible.collectibleId = data["collectibleId"]
    if "mint" in data:
        userCollectible.mint = data["mint"]
    if "previousOwnerId" in data:
        userCollectible.previousOwnerId = data["previousOwnerId"]
    if "lastTransferredDt" in data:
        if isinstance(data["lastTransferredDt"], str):
            userCollectible.lastTransferredDt = datetime.datetime.fromisoformat(data["lastTransferredDt"])
        else:
            userCollectible.lastTransferredDt = data["lastTransferredDt"]
    if "active" in data:
        userCollectible.active = data["active"]
    if "favorite" in data:
        userCollectible.favorite = data["favorite"]
    return userCollectible

def updateUserCollectibleByUserCollectibleId(event):
    data = extractData(event)
    if not data or "userCollectibleId" not in data:
        return {'statusCode': 400, 'body': 'userCollectibleId is required'}

    user_collectible_id = data["userCollectibleId"]
    user_collectible = UserCollectibleUpdate()
    user_collectible = UserCollectibleDataCheck(user_collectible, data)
    return crudFunctions.updateUserCollectibleByUserCollectibleId(userCollectibleId=user_collectible_id, user_collectible_update_data=user_collectible, db=event['db_session'])
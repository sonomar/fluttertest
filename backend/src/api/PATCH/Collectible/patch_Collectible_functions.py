from tools.prod.prodTools import extractData
import database.CRUD.PATCH.Collectible.patch_Collectible_CRUD_functions as crudFunctions
from database.schema.PATCH.Collectible.collectible_schema import CollectibleUpdate
import datetime

def CollectibleDataCheck(collectible: CollectibleUpdate, data: any):
    if "collectionId" in data:
        collectible.collectionId = data["collectionId"]
    if "categoryId" in data:
        collectible.categoryId = data["categoryId"]
    if "projectId" in data:
        collectible.projectId = data["projectId"]
    if "communityId" in data:
        collectible.communityId = data["communityId"]
    if "label" in data:
        collectible.label = data["label"]
    if "name" in data:
        collectible.name = data["name"]
    if "description" in data:
        collectible.description = data["description"]
    if "imageRef" in data:
        collectible.imageRef = data["imageRef"]
    if "vidRef" in data:
        collectible.vidRef = data["vidRef"]
    if "qrRef" in data:
        collectible.qrRef = data["qrRef"]
    if "embedRef" in data:
        collectible.embedRef = data["embedRef"]
    if "circulation" in data:
        collectible.circulation = data["circulation"]
    if "publicationDate" in data:
        if isinstance(data["publicationDate"], str):
            collectible.publicationDate = datetime.datetime.fromisoformat(data["publicationDate"])
        else:
            collectible.publicationDate = data["publicationDate"]
    if "active" in data:
        collectible.active = data["active"]
    return collectible

def updateCollectibleByCollectibleId(event):
    data = extractData(event)
    if not data or "collectibleId" not in data:
        return {'statusCode': 400, 'body': 'collectibleId is required'}

    collectible_id = data["collectibleId"]
    collectible = CollectibleUpdate()
    collectible = CollectibleDataCheck(collectible, data)
    return crudFunctions.updateCollectibleByCollectibleId(collectibleId=collectible_id, user_update_data=collectible, db=event['db_session'])
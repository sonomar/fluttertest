from tools.prod.prodTools import extractData
import database.CRUD.PATCH.Collection.patch_Collection_CRUD_functions as crudFunctions
from database.schema.PATCH.Collection.collection_schema import CollectionUpdate

def CollectionDataCheck(collection: CollectionUpdate, data: any):
    if "communityId" in data:
        collection.communityId = data["communityId"]
    if "name" in data:
        collection.name = data["name"]
    if "description" in data:
        collection.description = data["description"]
    if "imageRef" in data:
        collection.imageRef = data["imageRef"]
    if "vidRef" in data:
        collection.vidRef = data["vidRef"]
    if "qrRef" in data:
        collection.qrRef = data["qrRef"]
    if "embedRef" in data:
        collection.embedRef = data["embedRef"]
    if "active" in data:
        collection.active = data["active"]
    return collection

def updateCollectionByCollectionId(event):
    data = extractData(event)
    if not data or "collectionId" not in data:
        return {'statusCode': 400, 'body': 'collectionId is required'}

    collection_id = data["collectionId"]
    collection = CollectionUpdate()
    collection = CollectionDataCheck(collection, data)
    return crudFunctions.updateCollectionByCollectionId(collectionId=collection_id, collection_update_data=collection, db=event['db_session'])
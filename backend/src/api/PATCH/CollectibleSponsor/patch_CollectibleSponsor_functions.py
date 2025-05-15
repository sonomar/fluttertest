from tools.prod.prodTools import extractData
import database.CRUD.PATCH.CollectibleSponsor.patch_CollectibleSponsor_CRUD_functions as crudFunctions
from database.schema.PATCH.CollectibleSponsor.collectibleSponsor_schema import CollectibleSponsorUpdate

def CollectibleSponsorDataCheck(collectibleSponsor: CollectibleSponsorUpdate, data: any):
    if "collectibleId" in data:
        collectibleSponsor.collectibleId = data["collectibleId"]
    if "sponsorId" in data:
        collectibleSponsor.sponsorId = data["sponsorId"]
    if "sponsorMessage" in data:
        collectibleSponsor.sponsorMessage = data["sponsorMessage"]
    if "active" in data:
        collectibleSponsor.active = data["active"]
    return collectibleSponsor

def updateCollectibleSponsorByCollectibleSponsorId(event):
    data = extractData(event)
    if not data or "collectibleSponsorId" not in data:
        return {'statusCode': 400, 'body': 'collectibleSponsorId is required'}

    collectible_sponsor_id = data["collectibleSponsorId"]
    collectible_sponsor = CollectibleSponsorUpdate()
    collectible_sponsor = CollectibleSponsorDataCheck(collectible_sponsor, data)
    return crudFunctions.updateCollectibleSponsorByCollectibleSponsorId(collectibleSponsorId=collectible_sponsor_id, collectible_sponsor_update_data=collectible_sponsor, db=event['db_session'])
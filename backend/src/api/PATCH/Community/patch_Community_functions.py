from tools.prod.prodTools import extractData
import database.CRUD.PATCH.Community.patch_Community_CRUD_functions as crudFunctions
from database.schema.PATCH.Community.community_schema import CommunityUpdate

def CommunityDataCheck(community: CommunityUpdate, data: any):
    if "title" in data:
        community.title = data["title"]
    if "description" in data:
        community.description = data["description"]
    if "imageRef" in data:
        community.imageRef = data["imageRef"]
    if "vidRef" in data:
        community.vidRef = data["vidRef"]
    if "qrRef" in data:
        community.qrRef = data["qrRef"]
    if "embedRef" in data:
        community.embedRef = data["embedRef"]
    if "active" in data:
        community.active = data["active"]
    return community

def updateCommunityByCommunityId(event):
    data = extractData(event)
    if not data or "communityId" not in data:
        return {'statusCode': 400, 'body': 'communityId is required'}

    community_id = data["communityId"]
    community = CommunityUpdate()
    community = CommunityDataCheck(community, data)
    return crudFunctions.updateCommunityByCommunityId(communityId=community_id, community_update_data=community, db=event['db_session'])
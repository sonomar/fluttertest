from tools.prod.prodTools import extractData
import database.CRUD.PATCH.CommunityUser.patch_CommunityUser_CRUD_functions as crudFunctions
from database.schema.PATCH.CommunityUser.communityUser_schema import CommunityUserUpdate

def CommunityUserDataCheck(communityUser: CommunityUserUpdate, data: any):
    if "communityId" in data:
        communityUser.communityId = data["communityId"]
    if "memberId" in data:
        communityUser.memberId = data["memberId"]
    return communityUser

def updateCommunityUserByCommunityUserId(event):
    data = extractData(event)
    if not data or "communityUserId" not in data:
        return {'statusCode': 400, 'body': 'communityUserId is required'}

    community_user_id = data["communityUserId"]
    community_user = CommunityUserUpdate()
    community_user = CommunityUserDataCheck(community_user, data)
    return crudFunctions.updateCommunityUserByCommunityUserId(communityUserId=community_user_id, community_user_update_data=community_user, db=event['db_session'])
from tools.prod.prodTools import extractData
import database.CRUD.DELETE.CommunityUser.delete_CommunityUser_CRUD_functions as crudFunctions



def deleteCommunityUserByCommunityUserId(event):
    """
    Deletes a CommunityUser record by communityUserId.
    Requires 'communityUserId'.
    """
    data = extractData(event)
    if not data or "communityUserId" not in data:
        return {'statusCode': 400, 'body': 'communityUserId is required'}

    communityUser_id = data["communityUserId"]
    return crudFunctions.deleteCommunityUserByCommunityUserId(communityUserId=communityUser_id,db=event['db_session'])
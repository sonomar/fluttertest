from tools.prod.prodTools import extractData
import database.CRUD.DELETE.Community.delete_Community_CRUD_functions as crudFunctions



def deleteCommunityByCommunityId(event):
    """
    Deletes a Community record by communityId.
    Requires 'communityId'.
    """
    data = extractData(event)
    if not data or "communityId" not in data:
        return {'statusCode': 400, 'body': 'communityId is required'}

    community_id = data["communityId"]
    return crudFunctions.deleteCommunityByCommunityId(communityId=community_id,db=event['db_session'])
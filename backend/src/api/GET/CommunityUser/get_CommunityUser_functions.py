# database/CRUD/GET/CommunityUser/get_CommunityUser_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.CommunityUser.get_CommunityUser_CRUD_functions as crudFunctions

def getCommunityUsersByUserId(event):
    """
    Retrieves community user records by user ID.
    Requires 'userId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "userId" not in data:
        return {'statusCode': 400, 'body': 'userId is required'}

    user_id = data["userId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCommunityUsersByUserId(userId=user_id, skip=skip, limit=limit, db=event['db_session'])

def getCommunityUsersByCommunityId(event):
    """
    Retrieves community user records by community ID.
    Requires 'communityId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "communityId" not in data:
        return {'statusCode': 400, 'body': 'communityId is required'}

    community_id = data["communityId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCommunityUsersByCommunityId(communityId=community_id, skip=skip, limit=limit, db=event['db_session'])
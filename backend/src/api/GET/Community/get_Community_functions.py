# database/CRUD/GET/Community/get_Community_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.Community.get_Community_CRUD_functions as crudFunctions

def getCommunityByCommunityId(event):
    """
    Retrieves a community by its communityId.
    Requires 'communityId' in the request data.
    """
    data = extractData(event)
    if not data or "communityId" not in data:
        return {'statusCode': 400, 'body': 'communityId is required'}

    community_id = data["communityId"]
    return crudFunctions.getCommunityByCommunityId(communityId=community_id, db=event['db_session'])

def getCommunityByTitle(event):
    """
    Retrieves communities by their title.
    Requires 'title' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "title" not in data:
        return {'statusCode': 400, 'body': 'title is required'}

    title = data["title"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCommunityByTitle(title=title, skip=skip, limit=limit, db=event['db_session'])
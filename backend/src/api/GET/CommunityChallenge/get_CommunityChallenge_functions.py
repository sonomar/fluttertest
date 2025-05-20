# database/CRUD/GET/CommunityChallenge/get_CommunityChallenge_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.CommunityChallenge.get_CommunityChallenge_CRUD_functions as crudFunctions

def getCommunityChallengeByCommunityChallengeId(event):
    """
    Retrieves a community challenge by its communityChallengeId.
    Requires 'communityChallengeId' in the request data.
    """
    data = extractData(event)
    if not data or "communityChallengeId" not in data:
        return {'statusCode': 400, 'body': 'communityChallengeId is required'}

    community_challenge_id = data["communityChallengeId"]
    return crudFunctions.getCommunityChallengeByCommunityChallengeId(communityChallengeId=community_challenge_id, db=event['db_session'])

def getCommunityChallengeByTitle(event):
    """
    Retrieves community challenges by their title.
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

    return crudFunctions.getCommunityChallengeByTitle(title=title, skip=skip, limit=limit, db=event['db_session'])
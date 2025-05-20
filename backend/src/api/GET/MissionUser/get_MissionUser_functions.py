# database/CRUD/GET/MissionUser/get_MissionUser_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.MissionUser.get_MissionUser_CRUD_functions as crudFunctions

def getMissionUsersByUserId(event):
    """
    Retrieves mission user records by user ID.
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

    return crudFunctions.getMissionUsersByUserId(userId=user_id, skip=skip, limit=limit, db=event['db_session'])

def getMissionUsersByChallengeId(event):
    """
    Retrieves mission user records by mission ID (named 'challengeId' in the prompt).
    Requires 'missionId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "missionId" not in data: # Using missionId as per models.py
        return {'statusCode': 400, 'body': 'missionId is required'}

    mission_id = data["missionId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getMissionUsersByChallengeId(missionId=mission_id, skip=skip, limit=limit, db=event['db_session'])

def getMissionUsersByCompleted(event):
    """
    Retrieves mission user records by completion status.
    Requires 'completed' (boolean) in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "completed" not in data:
        return {'statusCode': 400, 'body': 'completed status is required'}

    completed = data["completed"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getMissionUsersByCompleted(completed=completed, skip=skip, limit=limit, db=event['db_session'])
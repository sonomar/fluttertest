# database/CRUD/GET/MissionUserData/get_MissionUserData_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.MissionUserData.get_MissionUserData_CRUD_functions as crudFunctions

def getMissionUserDatasByChallengeUserId(event):
    """
    Retrieves mission user data records by mission user ID (named 'challengeUserId' in the prompt).
    Requires 'missionUserId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "missionUserId" not in data: # Using missionUserId as per models.py
        return {'statusCode': 400, 'body': 'missionUserId is required'}

    mission_user_id = data["missionUserId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getMissionUserDatasByChallengeUserId(missionUserId=mission_user_id, skip=skip, limit=limit, db=event['db_session'])

def getMissionUserDatasByUserId(event):
    """
    Retrieves mission user data records by user ID.
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

    return crudFunctions.getMissionUserDatasByUserId(userId=user_id, skip=skip, limit=limit, db=event['db_session'])

def getMissionUserDatasByChallengeId(event):
    """
    Retrieves mission user data records by mission ID (named 'challengeId' in the prompt).
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

    return crudFunctions.getMissionUserDatasByChallengeId(missionId=mission_id, skip=skip, limit=limit, db=event['db_session'])
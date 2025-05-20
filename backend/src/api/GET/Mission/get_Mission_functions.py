# database/CRUD/GET/Mission/get_Mission_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.Mission.get_Mission_CRUD_functions as crudFunctions

def getMissionByMissionId(event):
    """
    Retrieves a mission by its missionId.
    Requires 'missionId' in the request data.
    """
    data = extractData(event)
    if not data or "missionId" not in data:
        return {'statusCode': 400, 'body': 'missionId is required'}

    mission_id = data["missionId"]
    return crudFunctions.getMissionByMissionId(missionId=mission_id, db=event['db_session'])

def getMissionByTitle(event):
    """
    Retrieves missions by their title.
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

    return crudFunctions.getMissionByTitle(title=title, skip=skip, limit=limit, db=event['db_session'])
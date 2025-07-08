from tools.prod.prodTools import extractData
import database.CRUD.GET.MissionType.get_MissionType_CRUD_functions as crudFunctions

def getMissionTypeByMissionTypeId(event):
    data = extractData(event)
    if not data or "missionTypeId" not in data:
        return {'statusCode': 400, 'body': 'missionTypeId is required'}
    
    mission_type_id = data["missionTypeId"]
    return crudFunctions.getMissionTypeByMissionTypeId(missionTypeId=mission_type_id, db=event['db_session'])

def getAllMissionTypes(event):
    data = extractData(event)
    skip = 0
    limit = 100
    if data:
        skip = data.get("skip", 0)
        limit = data.get("limit", 100)
        
    return crudFunctions.getAllMissionTypes(skip=skip, limit=limit, db=event['db_session'])
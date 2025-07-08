from tools.prod.prodTools import extractData
import database.CRUD.DELETE.MissionType.delete_MissionType_CRUD_functions as crudFunctions

def deleteMissionTypeByMissionTypeId(event):
    data = extractData(event)
    if not data or "missionTypeId" not in data:
        return {'statusCode': 400, 'body': 'missionTypeId is required'}
    
    mission_type_id = data["missionTypeId"]
    
    return crudFunctions.deleteMissionTypeByMissionTypeId(missionTypeId=mission_type_id, db=event['db_session'])
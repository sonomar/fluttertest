from tools.prod.prodTools import extractData
import database.CRUD.PATCH.MissionType.patch_MissionType_CRUD_functions as crudFunctions
from database.schema.PATCH.MissionType.missionType_schema import MissionTypeUpdate

def updateMissionTypeByMissionTypeId(event):
    data = extractData(event)
    if not data or "missionTypeId" not in data:
        return {'statusCode': 400, 'body': 'missionTypeId is required'}
    
    mission_type_id = data["missionTypeId"]
    mission_type = MissionTypeUpdate(**data)
    
    return crudFunctions.updateMissionTypeByMissionTypeId(missionTypeId=mission_type_id, mission_type=mission_type, db=event['db_session'])
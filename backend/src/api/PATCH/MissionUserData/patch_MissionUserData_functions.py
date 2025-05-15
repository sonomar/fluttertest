from tools.prod.prodTools import extractData
import database.CRUD.PATCH.MissionUserData.patch_MissionUserData_CRUD_functions as crudFunctions
from database.schema.PATCH.MissionUserData.missionUserData_schema import MissionUserDataUpdate

def MissionUserDataCheck(missionUserData: MissionUserDataUpdate, data: any):
    if "missionUserId" in data:
        missionUserData.missionUserId = data["missionUserId"]
    if "action" in data:
        missionUserData.action = data["action"]
    if "status" in data:
        missionUserData.status = data["status"]
    return missionUserData

def updateMissionUserDataByMissionUserDataId(event):
    data = extractData(event)
    if not data or "missionUserDataId" not in data:
        return {'statusCode': 400, 'body': 'missionUserDataId is required'}

    mission_user_data_id = data["missionUserDataId"]
    mission_user_data = MissionUserDataUpdate()
    mission_user_data = MissionUserDataCheck(mission_user_data, data)
    return crudFunctions.updateMissionUserDataByMissionUserDataId(missionUserDataId=mission_user_data_id, mission_user_data_update_data=mission_user_data, db=event['db_session'])
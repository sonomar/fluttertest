from tools.prod.prodTools import extractData
import database.CRUD.PATCH.MissionUser.patch_MissionUser_CRUD_functions as crudFunctions
from database.schema.PATCH.MissionUser.missionUser_schema import MissionUserUpdate
import datetime

def MissionUserDataCheck(missionUser: MissionUserUpdate, data: any):
    if "userId" in data:
        missionUser.userId = data["userId"]
    if "missionId" in data:
        missionUser.missionId = data["missionId"]
    if "progress" in data:
        missionUser.progress = data["progress"]
    if "status" in data:
        missionUser.status = data["status"]
    if "completed" in data:
        missionUser.completed = data["completed"]
    if "dateCompleted" in data:
        if isinstance(data["dateCompleted"], str):
            missionUser.dateCompleted = datetime.datetime.fromisoformat(data["dateCompleted"])
        else:
            missionUser.dateCompleted = data["dateCompleted"]
    if "rewardClaimed" in data:
        missionUser.rewardClaimed = data["rewardClaimed"]
    return missionUser

def updateMissionUserByMissionUserId(event):
    data = extractData(event)
    if not data or "missionUserId" not in data:
        return {'statusCode': 400, 'body': 'missionUserId is required'}

    mission_user_id = data["missionUserId"]
    mission_user = MissionUserUpdate()
    mission_user = MissionUserDataCheck(mission_user, data)
    return crudFunctions.updateMissionUserByMissionUserId(missionUserId=mission_user_id, mission_user_update_data=mission_user, db=event['db_session'])
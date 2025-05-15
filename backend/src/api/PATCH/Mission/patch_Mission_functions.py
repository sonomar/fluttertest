from tools.prod.prodTools import extractData
import database.CRUD.PATCH.Mission.patch_Mission_CRUD_functions as crudFunctions
from database.schema.PATCH.Mission.mission_schema import MissionUpdate
import datetime

def MissionDataCheck(mission: MissionUpdate, data: any):
    if "collectionId" in data:
        mission.collectionId = data["collectionId"]
    if "title" in data:
        mission.title = data["title"]
    if "description" in data:
        mission.description = data["description"]
    if "reward" in data:
        mission.reward = data["reward"]
    if "goal" in data:
        mission.goal = data["goal"]
    if "timer" in data:
        mission.timer = data["timer"]
    if "endDate" in data:
        if isinstance(data["endDate"], str):
            mission.endDate = datetime.datetime.fromisoformat(data["endDate"])
        else:
            mission.endDate = data["endDate"]
    if "imgRef" in data:
        mission.imgRef = data["imgRef"]
    if "vidRef" in data:
        mission.vidRef = data["vidRef"]
    if "qrRef" in data:
        mission.qrRef = data["qrRef"]
    if "embedRef" in data:
        mission.embedRef = data["embedRef"]
    return mission

def updateMissionByMissionId(event):
    data = extractData(event)
    if not data or "missionId" not in data:
        return {'statusCode': 400, 'body': 'missionId is required'}

    mission_id = data["missionId"]
    mission = MissionUpdate()
    mission = MissionDataCheck(mission, data)
    return crudFunctions.updateMissionByMissionId(missionId=mission_id, mission_update_data=mission, db=event['db_session'])
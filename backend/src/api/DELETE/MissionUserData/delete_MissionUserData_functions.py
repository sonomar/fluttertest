from tools.prod.prodTools import extractData
import database.CRUD.DELETE.MissionUserData.delete_MissionUserData_CRUD_functions as crudFunctions



def deleteMissionUserDataByMissionUserDataId(event):
    """
    Deletes a MissionUserData record by missionUserDataId.
    Requires 'missionUserDataId'.
    """
    data = extractData(event)
    if not data or "missionUserDataId" not in data:
        return {'statusCode': 400, 'body': 'missionUserDataId is required'}

    missionUserData_id = data["missionUserDataId"]
    return crudFunctions.deleteMissionUserDataByMissionUserDataId(missionUserDataId=missionUserData_id,db=event['db_session'])
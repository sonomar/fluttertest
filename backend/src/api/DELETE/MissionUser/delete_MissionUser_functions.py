from tools.prod.prodTools import extractData
import database.CRUD.DELETE.MissionUser.delete_MissionUser_CRUD_functions as crudFunctions



def deleteMissionUserByMissionUserId(event):
    """
    Deletes a MissionUser record by missionUserId.
    Requires 'missionUserId'.
    """
    data = extractData(event)
    if not data or "missionUserId" not in data:
        return {'statusCode': 400, 'body': 'missionUserId is required'}

    missionUser_id = ["missionUserId"]
    return crudFunctions.deleteMissionUserByMissionUserId(missionUserId=missionUser_id,db=event['db_session'])
from tools.prod.prodTools import extractData
import database.CRUD.DELETE.Mission.delete_Mission_CRUD_functions as crudFunctions



def deleteMissionByMissionId(event):
    """
    Deletes a Mission record by missionId.
    Requires 'missionId'.
    """
    data = extractData(event)
    if not data or "missionId" not in data:
        return {'statusCode': 400, 'body': 'missionId is required'}

    mission_id = data["missionId"]
    return crudFunctions.deleteMissionByMissionId(missionId=mission_id,db=event['db_session'])
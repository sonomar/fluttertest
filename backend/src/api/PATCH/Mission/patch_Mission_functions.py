from tools.prod.prodTools import extractData
import database.CRUD.PATCH.Mission.patch_Mission_CRUD_functions as crudFunctions
from database.schema.PATCH.Mission.mission_schema import MissionUpdate
from pydantic import ValidationError

def updateMissionByMissionId(event):
    """
    Updates an existing Mission. It extracts the data from the event,
    validates it using the MissionUpdate schema, and then calls the 
    corresponding CRUD function to perform the update in the database.
    """
    data = extractData(event)
    if not data or "missionId" not in data:
        return {'statusCode': 400, 'body': 'missionId is required in the request body'}

    mission_id = data.pop("missionId")

    try:
        # Pydantic will automatically parse the data, convert types (like ISO strings to datetime),
        # and validate all fields. The manual MissionDataCheck function is no longer needed.
        mission_update_data = MissionUpdate(**data)
    except ValidationError as e:
        # If the incoming data is invalid, return a 400 error with a detailed explanation.
        return {'statusCode': 400, 'body': e.errors()}

    return crudFunctions.updateMissionByMissionId(
        missionId=mission_id, 
        mission_update_data=mission_update_data, 
        db=event['db_session']
    )
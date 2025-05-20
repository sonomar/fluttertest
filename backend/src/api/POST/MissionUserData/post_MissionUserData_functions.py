# database/CRUD/POST/MissionUserData/post_MissionUserData_table.py
from tools.prod.prodTools import extractData, get_connection
from database.schema.POST.MissionUserData.missionUserData_schema import MissionUserDataCreate
import database.CRUD.POST.MissionUserData.post_MissionUserData_CRUD_functions as crudFunctions

def create_mission_user_data(event):
    """
    Adds new mission user data entry to the database.
    Requires 'missionUserId'. 'action' and 'status' are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "missionUserId" not in data:
        return {
            "statusCode": 400,
            "body": "missionUserId is required"
        }

    # Create Pydantic model instance
    mission_user_data = MissionUserDataCreate(
        missionUserId=data["missionUserId"],
        action=data.get("action"),
        status=data.get("status")
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.create_mission_user_data(mission_user_data=mission_user_data, db=event["db_session"])
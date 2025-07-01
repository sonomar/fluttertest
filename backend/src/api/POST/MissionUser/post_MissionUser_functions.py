# database/CRUD/POST/MissionUser/post_MissionUser_table.py
from tools.prod.prodTools import extractData, get_connection
from database.schema.POST.MissionUser.missionUser_schema import MissionUserCreate
import database.CRUD.POST.MissionUser.post_MissionUser_CRUD_functions as crudFunctions

def createMissionUser(event):
    """
    Adds a new mission user entry to the database.
    Requires 'userId', 'missionId'. Other fields are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "userId" not in data or "missionId" not in data:
        return {
            "statusCode": 400,
            "body": "userId and missionId are required"
        }

    # Create Pydantic model instance
    mission_user = MissionUserCreate(
        userId=data["userId"],
        missionId=data["missionId"],
        progress=data.get("progress"), # Schema default is 0 if not provided
        status=data.get("status"),
        completed=data.get("completed"), # Schema default is False if not provided
        dateCompleted=data.get("dateCompleted"),
        rewardClaimed=data.get("rewardClaimed") # Schema default is False if not provided
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.createMissionUser(mission_user=mission_user, db=event["db_session"])
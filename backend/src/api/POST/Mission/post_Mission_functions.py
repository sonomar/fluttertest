# database/CRUD/POST/Mission/post_Mission_table.py
from tools.prod.prodTools import extractData, get_connection
from database.schema.POST.Mission.mission_schema import MissionCreate
import database.CRUD.POST.Mission.post_Mission_CRUD_functions as crudFunctions

def create_mission(event):
    """
    Adds a new mission to the database.
    Requires 'collectionId', 'title', 'goal'. Other fields are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "collectionId" not in data or "title" not in data or "goal" not in data:
        return {
            "statusCode": 400,
            "body": "collectionId, title, and goal are required"
        }

    # Create Pydantic model instance
    mission = MissionCreate(
        collectionId=data["collectionId"],
        title=data["title"],
        goal=data["goal"],
        description=data.get("description"),
        reward=data.get("reward"),
        timer=data.get("timer"), # Schema default is False if not provided
        endDate=data.get("endDate"),
        imgRef=data.get("imgRef"),
        vidRef=data.get("vidRef"),
        qrRef=data.get("qrRef"),
        embedRef=data.get("embedRef")
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.create_mission(mission=mission, db=event["db_session"])
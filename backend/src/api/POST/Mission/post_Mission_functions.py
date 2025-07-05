from tools.prod.prodTools import extractData
from database.schema.POST.Mission.mission_schema import MissionCreate
import database.CRUD.POST.Mission.post_Mission_CRUD_functions as crudFunctions
from pydantic import ValidationError

def createMission(event):
    """
    Adds a new mission to the database. It validates the request data
    using the MissionCreate schema and then calls the corresponding CRUD function.
    """
    data = extractData(event)
    if not data:
        return {'statusCode': 400, 'body': 'Request body is missing'}

    try:
        # Pydantic will automatically validate that 'collectionId', 'title', and 'goal' are present,
        # and handle all other optional fields from the updated schema.
        mission_data = MissionCreate(**data)
    except ValidationError as e:
        # If validation fails, return a detailed 400 Bad Request error.
        return {'statusCode': 400, 'body': e.errors()}

    # Call the CRUD function with the validated Pydantic model.
    # The CRUD function name is also updated to snake_case for consistency.
    return crudFunctions.createMission(
        mission=mission_data, 
        db=event["db_session"]
    )
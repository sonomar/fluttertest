from tools.prod.prodTools import extractData
from database.schema.POST.MissionType.missionType_schema import MissionTypeCreate
import database.CRUD.POST.MissionType.post_MissionType_CRUD_functions as crudFunctions

def createMissionType(event):
    data = extractData(event)
    if not data:
        return {'statusCode': 400, 'body': 'Request body is missing'}

    # Basic validation for required fields
    required_fields = ["name"]
    if not all(field in data for field in required_fields):
        return {
            "statusCode": 400,
            "body": "Missing one or more required fields: name"
        }
        
    mission_type = MissionTypeCreate(**data)
    
    return crudFunctions.createMissionType(mission_type=mission_type, db=event["db_session"])
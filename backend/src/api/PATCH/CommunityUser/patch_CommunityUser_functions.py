from tools.prod.prodTools import extractData
import database.CRUD.PATCH.CommunityUser.patch_CommunityUser_CRUD_functions as crudFunctions
from database.schema.PATCH.CommunityUser.communityUser_schema import CommunityUserUpdate
from pydantic import ValidationError

def updateCommunityUserByCommunityUserId(event):
    """
    Updates an existing CommunityUser record. It extracts the data from the event,
    validates it using the CommunityUserUpdate schema, and then calls the 
    corresponding CRUD function to perform the update.
    """
    data = extractData(event)
    if not data or "communityUserId" not in data:
        return {'statusCode': 400, 'body': 'communityUserId is required in the request body'}

    community_user_id = data.pop("communityUserId")

    try:
        # Pydantic automatically validates the incoming data. The manual
        # CommunityUserDataCheck function is no longer needed.
        community_user_update_data = CommunityUserUpdate(**data)
    except ValidationError as e:
        # If validation fails, return a 400 error with specific details.
        return {'statusCode': 400, 'body': e.errors()}

    return crudFunctions.updateCommunityUserByCommunityUserId(
        communityUserId=community_user_id, 
        community_user_update_data=community_user_update_data, 
        db=event['db_session']
    )
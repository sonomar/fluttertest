from tools.prod.prodTools import extractData
import database.CRUD.PATCH.UserCollectible.patch_UserCollectible_CRUD_functions as crudFunctions
from database.schema.PATCH.UserCollectible.userCollectible_schema import UserCollectibleUpdate
from pydantic import ValidationError

def updateUserCollectibleByUserCollectibleId(event):
    """
    Updates an existing UserCollectible record. It extracts the data from the event,
    validates it using the UserCollectibleUpdate schema, and then calls the 
    corresponding CRUD function to perform the update.
    """
    data = extractData(event)
    if not data or "userCollectibleId" not in data:
        return {'statusCode': 400, 'body': 'userCollectibleId is required in the request body'}

    user_collectible_id = data.pop("userCollectibleId")

    try:
        # Pydantic will automatically validate and parse the incoming data.
        # The manual UserCollectibleDataCheck function is no longer needed.
        user_collectible_update_data = UserCollectibleUpdate(**data)
    except ValidationError as e:
        # If the incoming data is invalid (e.g., wrong data types),
        # return a 400 Bad Request with a detailed error message.
        return {'statusCode': 400, 'body': e.errors()}

    return crudFunctions.updateUserCollectibleByUserCollectibleId(
        userCollectibleId=user_collectible_id,
        user_collectible_update_data=user_collectible_update_data,
        db=event['db_session']
    )
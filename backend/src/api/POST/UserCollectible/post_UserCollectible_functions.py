from tools.prod.prodTools import extractData
from database.schema.POST.UserCollectible.userCollectible_schema import UserCollectibleCreate
import database.CRUD.POST.UserCollectible.post_UserCollectible_CRUD_functions as crudFunctions
from pydantic import ValidationError

def createUserCollectible(event):
    """
    Adds a new user collectible entry to the database. It validates the request data
    using the UserCollectibleCreate schema and then calls the corresponding CRUD function.
    """
    data = extractData(event)
    if not data:
        return {'statusCode': 400, 'body': 'Request body is missing'}

    try:
        # Pydantic will automatically validate required fields ('ownerId', 'collectibleId', 'mint')
        # and handle all other optional fields from the updated schema.
        user_collectible_data = UserCollectibleCreate(**data)
    except ValidationError as e:
        # If validation fails, return a detailed 400 Bad Request error.
        return {'statusCode': 400, 'body': e.errors()}

    # Call the CRUD function with the validated Pydantic model.
    # The CRUD function name is also updated to snake_case for consistency.
    return crudFunctions.createUserCollectible(
        user_collectible=user_collectible_data,
        db=event["db_session"]
    )
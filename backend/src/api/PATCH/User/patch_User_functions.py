from tools.prod.prodTools import extractData
import database.CRUD.PATCH.User.patch_User_CRUD_functions as crudFunctions
from database.schema.PATCH.User.user_schema import UserUpdate
from pydantic import ValidationError
import datetime

def updateUserByUserId(event):
    """
    Updates user information based on userId.
    """
    data = extractData(event)
    if not data or "userId" not in data:
        return {'statusCode': 400, 'body': 'userId is required'}

    user_id = data.pop("userId")  # Remove userId to avoid it being part of the update model

    try:
        # Create the UserUpdate instance directly from the request data.
        # Pydantic will automatically validate and convert "userType": "admin"
        # into the correct UserTypeEnum.admin.
        user_update_data = UserUpdate(**data)
    except ValidationError as e:
        # If validation fails (e.g., an invalid userType is passed),
        # return a clear error.
        return {'statusCode': 400, 'body': e.errors()}

    # Call the CRUD function with the correctly populated and validated model.
    return crudFunctions.updateUserByUserId(
        userId=user_id,
        user_update_data=user_update_data,
        db=event['db_session']
    )


def updateUserByUsername(event):
    """
    Updates user information based on username.
    """
    data = extractData(event)
    if not data or "username" not in data:
        return {'statusCode': 400, 'body': 'username is required'}

    username = data.pop("username") # Remove username to avoid it being part of the update model

    try:
        # Create the UserUpdate instance directly from the request data.
        user_update_data = UserUpdate(**data)
    except ValidationError as e:
        return {'statusCode': 400, 'body': e.errors()}
    
    return crudFunctions.updateUserByUsername(
        current_username=username,
        user_update_data=user_update_data,
        db=event['db_session']
    )
from tools.prod.prodTools import extractData
from database.schema.POST.CommunityUser.communityUser_schema import CommunityUserCreate
import database.CRUD.POST.CommunityUser.post_CommunityUser_CRUD_functions as crudFunctions
from pydantic import ValidationError

def createCommunityUser(event):
    """
    Adds a new community user entry to the database. It validates the request data
    using the CommunityUserCreate schema and then calls the corresponding CRUD function.
    """
    data = extractData(event)
    if not data:
        return {'statusCode': 400, 'body': 'Request body is missing'}

    try:
        # Pydantic will automatically validate that 'communityId' and 'memberId' are present.
        # The manual check is no longer needed.
        community_user_data = CommunityUserCreate(**data)
    except ValidationError as e:
        # If validation fails, return a 400 error with a detailed message.
        return {'statusCode': 400, 'body': e.errors()}

    # Call the CRUD function with the validated Pydantic model.
    # Note: The CRUD function name is also updated to snake_case for consistency.
    return crudFunctions.createCommunityUser(
        community_user=community_user_data, 
        db=event["db_session"]
    )
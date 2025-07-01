# database/CRUD/POST/CommunityUser/post_CommunityUser_table.py
from tools.prod.prodTools import extractData
from database.schema.POST.CommunityUser.communityUser_schema import CommunityUserCreate
import database.CRUD.POST.CommunityUser.post_CommunityUser_CRUD_functions as crudFunctions

def createCommunityUser(event):
    """
    Adds a new community user entry to the database.
    Requires 'communityId', 'memberId'.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "communityId" not in data or "memberId" not in data:
        return {
            "statusCode": 400,
            "body": "communityId and memberId are required"
        }

    # Create Pydantic model instance
    community_user = CommunityUserCreate(
        communityId=data["communityId"],
        memberId=data["memberId"]
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.createCommunityUser(community_user=community_user, db=event["db_session"])
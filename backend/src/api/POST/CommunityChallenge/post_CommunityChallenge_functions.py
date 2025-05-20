# database/CRUD/POST/CommunityChallenge/post_CommunityChallenge_table.py
from tools.prod.prodTools import extractData
from database.schema.POST.CommunityChallenge.communityChallenge_schema import CommunityChallengeCreate
import database.CRUD.POST.CommunityChallenge.post_CommunityChallenge_CRUD_functions as crudFunctions

def create_community_challenge(event):
    """
    Adds a new community challenge to the database.
    Requires 'communityId', 'title', 'goal'. Other fields are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "communityId" not in data or "title" not in data or "goal" not in data:
        return {
            "statusCode": 400,
            "body": "communityId, title, and goal are required"
        }

    # Create Pydantic model instance
    community_challenge = CommunityChallengeCreate(
        communityId=data["communityId"],
        title=data["title"],
        goal=data["goal"],
        timer=data.get("timer"), # Schema default is False if not provided
        description=data.get("description"),
        reward=data.get("reward"),
        startDate=data.get("startDate"),
        endDate=data.get("endDate"),
        imgRef=data.get("imgRef"),
        vidRef=data.get("vidRef"),
        qrRef=data.get("qrRef"),
        embedRef=data.get("embedRef")
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.create_community_challenge(community_challenge=community_challenge, db=event["db_session"])
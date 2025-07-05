from tools.prod.prodTools import extractData
from database.schema.POST.CommunityChallenge.communityChallenge_schema import CommunityChallengeCreate
import database.CRUD.POST.CommunityChallenge.post_CommunityChallenge_CRUD_functions as crudFunctions
from pydantic import ValidationError

def createCommunityChallenge(event):
    """
    Adds a new community challenge to the database.
    Validates the request data using the CommunityChallengeCreate schema and
    calls the corresponding CRUD function to create the record.
    """
    data = extractData(event)
    if not data:
        return {'statusCode': 400, 'body': 'Request body is missing'}

    try:
        # Pydantic will automatically validate required fields (communityId, title, goal)
        # and handle optional fields with their defaults. The manual check is no longer needed.
        community_challenge_data = CommunityChallengeCreate(**data)
    except ValidationError as e:
        # If validation fails, Pydantic raises an error. We catch it and
        # return a detailed error message to the client.
        return {'statusCode': 400, 'body': e.errors()}

    # Call the CRUD function with the validated Pydantic model.
    # Assumes event["db_session"] contains the SQLAlchemy session.
    return crudFunctions.createCommunityChallenge(
        community_challenge=community_challenge_data, 
        db=event["db_session"]
    )
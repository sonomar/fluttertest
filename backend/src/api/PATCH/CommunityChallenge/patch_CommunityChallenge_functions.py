from tools.prod.prodTools import extractData
import database.CRUD.PATCH.CommunityChallenge.patch_CommunityChallenge_CRUD_functions as crudFunctions
from database.schema.PATCH.CommunityChallenge.communityChallenge_schema import CommunityChallengeUpdate
from pydantic import ValidationError

def updateCommunityChallengeByCommunityChallengeId(event):
    """
    Updates an existing Community Challenge. It extracts the data from the event,
    validates it using the CommunityChallengeUpdate schema, and then calls the 
    corresponding CRUD function to perform the update in the database.
    """
    data = extractData(event)
    if not data or "communityChallengeId" not in data:
        return {'statusCode': 400, 'body': 'communityChallengeId is required in the request body'}

    community_challenge_id = data.pop("communityChallengeId")

    try:
        # Pydantic will automatically parse the data, convert types (like ISO strings to datetime),
        # and validate the fields. The manual CommunityChallengeDataCheck function is no longer needed.
        community_challenge_update_data = CommunityChallengeUpdate(**data)
    except ValidationError as e:
        # If the data is invalid, return a 400 error with the validation details.
        return {'statusCode': 400, 'body': e.errors()}

    return crudFunctions.updateCommunityChallengeByCommunityChallengeId(
        communityChallengeId=community_challenge_id, 
        community_challenge_update_data=community_challenge_update_data, 
        db=event['db_session']
    )
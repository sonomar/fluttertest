from tools.prod.prodTools import extractData
import database.CRUD.DELETE.CommunityChallenge.delete_CommunityChallenge_CRUD_functions as crudFunctions



def deleteCommunityChallengeByCommunityChallengeId(event):
    """
    Deletes a CommunityChallenge record by communityChallengeId.
    Requires 'communityChallengeId'.
    """
    data = extractData(event)
    if not data or "communityChallengeId" not in data:
        return {'statusCode': 400, 'body': 'communityChallengeId is required'}

    communityChallenge_id = data["communityChallengeId"]
    return crudFunctions.deleteCommunityChallengeByCommunityChallengeId(communityChallengeId=communityChallenge_id,db=event['db_session'])
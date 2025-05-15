from tools.prod.prodTools import extractData
import database.CRUD.PATCH.CommunityChallenge.patch_CommunityChallenge_CRUD_functions as crudFunctions
from database.schema.PATCH.CommunityChallenge.communityChallenge_schema import CommunityChallengeUpdate
import datetime

def CommunityChallengeDataCheck(communityChallenge: CommunityChallengeUpdate, data: any):
    if "communityId" in data:
        communityChallenge.communityId = data["communityId"]
    if "title" in data:
        communityChallenge.title = data["title"]
    if "goal" in data:
        communityChallenge.goal = data["goal"]
    if "timer" in data:
        communityChallenge.timer = data["timer"]
    if "description" in data:
        communityChallenge.description = data["description"]
    if "reward" in data:
        communityChallenge.reward = data["reward"]
    if "startDate" in data:
        if isinstance(data["startDate"], str):
            communityChallenge.startDate = datetime.datetime.fromisoformat(data["startDate"])
        else:
            communityChallenge.startDate = data["startDate"]
    if "endDate" in data:
        if isinstance(data["endDate"], str):
            communityChallenge.endDate = datetime.datetime.fromisoformat(data["endDate"])
        else:
            communityChallenge.endDate = data["endDate"]
    if "imgRef" in data:
        communityChallenge.imgRef = data["imgRef"]
    if "vidRef" in data:
        communityChallenge.vidRef = data["vidRef"]
    if "qrRef" in data:
        communityChallenge.qrRef = data["qrRef"]
    if "embedRef" in data:
        communityChallenge.embedRef = data["embedRef"]
    return communityChallenge

def updateCommunityChallengeByCommunityChallengeId(event):
    data = extractData(event)
    if not data or "communityChallengeId" not in data:
        return {'statusCode': 400, 'body': 'communityChallengeId is required'}

    community_challenge_id = data["communityChallengeId"]
    community_challenge = CommunityChallengeUpdate()
    community_challenge = CommunityChallengeDataCheck(community_challenge, data)
    return crudFunctions.updateCommunityChallengeByCommunityChallengeId(communityChallengeId=community_challenge_id, community_challenge_update_data=community_challenge, db=event['db_session'])
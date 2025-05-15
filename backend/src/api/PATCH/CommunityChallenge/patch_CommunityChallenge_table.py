import api.PATCH.CommunityChallenge.patch_CommunityChallenge_functions as communityChallenge
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_CommunityChallenge_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    CommunityChallenge_Path = API_PATHS_PATCH['CommunityChallenge']

    ## CommunityChallenge
    if raw_path == CommunityChallenge_Path['updateCommunityChallengeByCommunityChallengeId']['path']:
        returnString = communityChallenge.updateCommunityChallengeByCommunityChallengeId(event)

    return returnString
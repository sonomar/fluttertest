import api.DELETE.CommunityChallenge.delete_CommunityChallenge_functions as communityChallengeFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_CommunityChallenge_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    CommunityChallenge_Path = API_PATHS_DELETE['CommunityChallenge']

    ## CommunityChallenge
    if raw_path == CommunityChallenge_Path['deleteCommunityChallengeByCommunityChallengeId']['path']:
        returnString = communityChallengeFunctions.deleteCommunityChallengeByCommunityChallengeId(event)

    return returnString
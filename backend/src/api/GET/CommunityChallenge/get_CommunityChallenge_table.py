import api.GET.CommunityChallenge.get_CommunityChallenge_functions as communityChallenge
from api.GET.api_paths_get import API_PATHS_GET

def call_CommunityChallenge_function(raw_path, event):

    returnString = 'Invalid Function Call'
    CommunityChallenge_Path = API_PATHS_GET['CommunityChallenge']

    ## CommunityChallenge
    if raw_path == CommunityChallenge_Path['getCommunityChallengeByCommunityChallengeId']['path']:
        returnString = communityChallenge.getCommunityChallengeByCommunityChallengeId(event)

    elif raw_path == CommunityChallenge_Path['getCommunityChallengeByTitle']['path']:
        returnString = communityChallenge.getCommunityChallengeByTitle(event)
    
    return returnString
import api.POST.CommunityChallenge.post_CommunityChallenge_functions as communityChallenge
from api.POST.api_paths_post import API_PATHS_POST

def call_CommunityChallenge_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    CommunityChallenge_Path = API_PATHS_POST['CommunityChallenge']

    ## CommunityChallenge
    if raw_path == CommunityChallenge_Path['createCommunityChallenge']['path']:
        returnString = communityChallenge.createCommunityChallenge(event)

    return returnString
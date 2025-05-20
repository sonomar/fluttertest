import api.GET.CommunityUser.get_CommunityUser_functions as communityUser
from api.GET.api_paths_get import API_PATHS_GET

def call_CommunityUser_function(raw_path, event):

    returnString = 'Invalid Function Call'
    CommunityUser_Path = API_PATHS_GET['CommunityUser']

    ## CommunityUser
    if raw_path == CommunityUser_Path['getCommunityUsersByUserId']['path']:
        returnString = communityUser.getCommunityUsersByUserId(event)

    elif raw_path == CommunityUser_Path['getCommunityUsersByCommunityId']['path']:
        returnString = communityUser.getCommunityUsersByCommunityId(event)
    
    return returnString
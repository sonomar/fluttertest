import api.PATCH.CommunityUser.patch_CommunityUser_functions as communityUser
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_CommunityUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    CommunityUser_Path = API_PATHS_PATCH['CommunityUser']

    ## CommunityUser
    if raw_path == CommunityUser_Path['updateCommunityUserByCommunityUserId']['path']:
        returnString = communityUser.updateCommunityUserByCommunityUserId(event)

    return returnString
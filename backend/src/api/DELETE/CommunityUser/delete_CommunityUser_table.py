import api.DELETE.CommunityUser.delete_CommunityUser_functions as communityUserFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_CommunityUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    CommunityUser_Path = API_PATHS_DELETE['CommunityUser']

    ## CommunityUser
    if raw_path == CommunityUser_Path['deleteCommunityUserByCommunityUserId']['path']:
        returnString = communityUserFunctions.deleteCommunityUserByCommunityUserId(event)

    return returnString
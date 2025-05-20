import api.POST.CommunityUser.post_CommunityUser_functions as communityUser
from api.POST.api_paths_post import API_PATHS_POST

def call_CommunityUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    CommunityUser_Path = API_PATHS_POST['CommunityUser']

    ## CommunityUser
    if raw_path == CommunityUser_Path['createCommunityUser']['path']:
        returnString = communityUser.create_community_user(event)

    return returnString
import api.PATCH.Community.patch_Community_functions as community
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_Community_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Community_Path = API_PATHS_PATCH['Community']

    ## Community
    if raw_path == Community_Path['updateCommunityByCommunityId']['path']:
        returnString = community.updateCommunityByCommunityId(event)

    return returnString
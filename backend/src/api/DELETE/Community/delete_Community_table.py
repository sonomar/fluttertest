import api.DELETE.Community.delete_Community_functions as communityFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_Community_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Community_Path = API_PATHS_DELETE['Community']

    ## Community
    if raw_path == Community_Path['deleteCommunityByCommunityId']['path']:
        returnString = communityFunctions.deleteCommunityByCommunityId(event)

    return returnString
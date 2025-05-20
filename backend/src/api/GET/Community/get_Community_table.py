import api.GET.Community.get_Community_functions as community
from api.GET.api_paths_get import API_PATHS_GET

def call_Community_function(raw_path, event):

    returnString = 'Invalid Function Call'
    Community_Path = API_PATHS_GET['Community']

    ## Community
    if raw_path == Community_Path['getCommunityByCommunityId']['path']:
        returnString = community.getCommunityByCommunityId(event)

    elif raw_path == Community_Path['getCommunityByTitle']['path']:
        returnString = community.getCommunityByTitle(event)

    
    return returnString
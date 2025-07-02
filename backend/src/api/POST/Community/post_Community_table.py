import api.POST.Community.post_Community_functions as community
from api.POST.api_paths_post import API_PATHS_POST

def call_Community_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Community_Path = API_PATHS_POST['Community']

    ## Community
    if raw_path == Community_Path['createCommunity']['path']:
        returnString = community.createCommunity(event)

    return returnString
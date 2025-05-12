import api.GET.UserCollectible.get_UserCollectible_functions as userCollectible
from api.GET.api_paths_get import API_PATHS_GET

def call_UserCollectible_function(raw_path, event):

    returnString = 'Invalid Function Call'
    UserCollectible_Path = API_PATHS_GET['UserCollectible']

    ## UserCollectible
    if raw_path == UserCollectible_Path['getUserCollectibleByUserId']:
        returnString = userCollectible.getUserCollectibleByUserId(event)
    
    return returnString
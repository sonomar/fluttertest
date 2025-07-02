import api.POST.UserCollectible.post_UserCollectible_functions as userCollectible
from api.POST.api_paths_post import API_PATHS_POST

def call_UserCollectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    UserCollectible_Path = API_PATHS_POST['UserCollectible']

    ## UserCollectible
    if raw_path == UserCollectible_Path['createUserCollectible']['path']:
        returnString = userCollectible.createUserCollectible(event)

    return returnString
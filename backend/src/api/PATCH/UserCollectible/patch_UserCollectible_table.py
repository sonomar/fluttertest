import api.PATCH.UserCollectible.patch_UserCollectible_functions as userCollectible
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_UserCollectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    UserCollectible_Path = API_PATHS_PATCH['UserCollectible']

    ## UserCollectible
    if raw_path == UserCollectible_Path['updateUserCollectibleByUserCollectibleId']['path']:
        returnString = userCollectible.updateUserCollectibleByUserCollectibleId(event)

    return returnString
import api.DELETE.UserCollectible.delete_UserCollectible_functions as userCollectibleFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_UserCollectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    UserCollectible_Path = API_PATHS_DELETE['UserCollectible']

    ## UserCollectible
    if raw_path == UserCollectible_Path['deleteUserCollectibleByUserCollectibleId']['path']:
        returnString = userCollectibleFunctions.deleteUserCollectibleByUserCollectibleId(event)

    return returnString
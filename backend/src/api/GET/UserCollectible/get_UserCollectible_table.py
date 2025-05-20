import api.GET.UserCollectible.get_UserCollectible_functions as userCollectible
from api.GET.api_paths_get import API_PATHS_GET

def call_UserCollectible_function(raw_path, event):

    returnString = 'Invalid Function Call'
    UserCollectible_Path = API_PATHS_GET['UserCollectible']

    ## UserCollectible
    if raw_path == UserCollectible_Path['getUserCollectibleByCollectibleIdAndMint']:
        returnString = userCollectible.getUserCollectibleByCollectibleIdAndMint(event)
    
    if raw_path == UserCollectible_Path['getUserCollectiblesByOwnerId']:
        returnString = userCollectible.getUserCollectiblesByOwnerId(event)

    if raw_path == UserCollectible_Path['getUserCollectiblesByLastOwned']:
        returnString = userCollectible.getUserCollectiblesByLastOwned(event)

    if raw_path == UserCollectible_Path['getUserCollectiblesByCollectibleId']:
        returnString = userCollectible.getUserCollectiblesByCollectibleId(event)
    
    return returnString
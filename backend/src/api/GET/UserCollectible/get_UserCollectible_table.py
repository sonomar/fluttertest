import api.GET.UserCollectible.get_UserCollectible_functions as userCollectible
import api.GET.api_path_get as api_path_get

def call_UserCollectible_function(raw_path, event):

    returnString = 'Invalid Function Call'

    ## UserCollectible
    if raw_path == api_path_get.GET_RAW_PATH_getUserCollectiblesByUserId:
        returnString = userCollectible.getUserCollectibleByUserId(event)
    
    return returnString
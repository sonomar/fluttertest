import api.GET.Collectible.get_Collectible_functions as collectible
import api.GET.api_path_get as api_path_get

def call_Collectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'

    ## Collectible
    if raw_path == api_path_get.GET_RAW_PATH_getAllCollectibles:
        returnString = collectible.getAllCollectibles(event)
    
    elif raw_path == api_path_get.GET_RAW_PATH_getCollectibleByCollectibleId:
        returnString = collectible.getCollectibleByCollectibleId(event)
    
    elif raw_path == api_path_get.GET_RAW_PATH_getCollectiblesByProjectId:
        returnString = collectible.getCollectiblesByProjectId(event)

    elif raw_path == api_path_get.GET_RAW_PATH_getCollectiblesByCategoryId:
        returnString = collectible.getCollectiblesByCategoryId(event)

    return returnString
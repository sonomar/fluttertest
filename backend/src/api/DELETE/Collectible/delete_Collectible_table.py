import api.DELETE.Collectible.delete_Collectible_functions as collectibleFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_Collectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Collectible_Path = API_PATHS_DELETE['Collectible']

    ## Collectible
    if raw_path == Collectible_Path['deleteCollectibleByCollectibleId']['path']:
        returnString = collectibleFunctions.deleteCollectibleByCollectibleId(event)

    return returnString
import api.PATCH.Collectible.patch_Collectible_functions as collectible
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_Collectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Collectible_Path = API_PATHS_PATCH['Collectible']

    ## Collectible
    if raw_path == Collectible_Path['updateCollectibleByCollectibleId']['path']:
        returnString = collectible.updateCollectibleByCollectibleId(event)

    return returnString
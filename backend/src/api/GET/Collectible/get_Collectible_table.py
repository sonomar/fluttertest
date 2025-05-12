import api.GET.Collectible.get_Collectible_functions as collectible
from api.GET.api_paths_get import API_PATHS_GET

def call_Collectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Collectible_Path = API_PATHS_GET['Collectible']

    ## Collectible
    if raw_path ==  Collectible_Path['getAllCollectibles']:
        returnString = collectible.getAllCollectibles(event)
    
    elif raw_path == Collectible_Path['getCollectibleByCollectibleId']:
        returnString = collectible.getCollectibleByCollectibleId(event)
    
    elif raw_path == Collectible_Path['getCollectiblesByProjectId']:
        returnString = collectible.getCollectiblesByProjectId(event)

    elif raw_path == Collectible_Path['getCollectiblesByCategoryId']:
        returnString = collectible.getCollectiblesByCategoryId(event)

    return returnString
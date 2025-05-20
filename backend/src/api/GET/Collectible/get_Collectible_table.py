import api.GET.Collectible.get_Collectible_functions as collectible
from api.GET.api_paths_get import API_PATHS_GET

def call_Collectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Collectible_Path = API_PATHS_GET['Collectible']

    ## Collectible
    if raw_path ==  Collectible_Path['getAllCollectibles']['path']:
        returnString = collectible.getAllCollectibles(event)
    
    elif raw_path == Collectible_Path['getCollectibleByCollectibleId']['path']:
        returnString = collectible.getCollectibleByCollectibleId(event)
    
    elif raw_path == Collectible_Path['getCollectiblesByProjectId']['path']:
        returnString = collectible.getCollectiblesByProjectId(event)

    elif raw_path == Collectible_Path['getCollectiblesByCategoryId']['path']:
        returnString = collectible.getCollectiblesByCategoryId(event)

    elif raw_path == Collectible_Path['getCollectiblesBySponsor']['path']:
        returnString = collectible.getCollectiblesBySponsor(event)

    elif raw_path == Collectible_Path['getCollectiblesByLabel']['path']:
        returnString = collectible.getCollectiblesByLabel(event)

    elif raw_path == Collectible_Path['getCollectibleByName']['path']:
        returnString = collectible.getCollectibleByName(event)

    elif raw_path == Collectible_Path['getCollectiblesByCollection']['path']:
        returnString = collectible.getCollectiblesByCollection(event)

    elif raw_path == Collectible_Path['getCollectiblesByCommunity']['path']:
        returnString = collectible.getCollectiblesByCommunity(event)

    return returnString
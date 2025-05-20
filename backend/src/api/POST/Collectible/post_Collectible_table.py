import api.POST.Collectible.post_Collectible_functions as collectible
from api.POST.api_paths_post import API_PATHS_POST

def call_Collectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Collectible_Path = API_PATHS_POST['Collectible']

    ## Collectible
    if raw_path == Collectible_Path['createCollectible']['path']:
        returnString = collectible.create_collectible(event)

    return returnString
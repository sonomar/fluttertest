import api.POST.CollectibleSponsor.post_CollectibleSponsor_functions as collectibleSponsor
from api.POST.api_paths_post import API_PATHS_POST

def call_CollectibleSponsor_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    CollectibleSponsor_Path = API_PATHS_POST['CollectibleSponsor']

    ## CollectibleSponsor
    if raw_path == CollectibleSponsor_Path['createCollectibleSponsor']['path']:
        returnString = collectibleSponsor.create_collectible_sponsor(event)

    return returnString
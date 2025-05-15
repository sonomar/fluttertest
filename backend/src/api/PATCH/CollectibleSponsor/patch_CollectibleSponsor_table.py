import api.PATCH.CollectibleSponsor.patch_CollectibleSponsor_functions as collectibleSponsor
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_CollectibleSponsor_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    CollectibleSponsor_Path = API_PATHS_PATCH['CollectibleSponsor']

    ## CollectibleSponsor
    if raw_path == CollectibleSponsor_Path['updateCollectibleSponsorByCollectibleSponsorId']['path']:
        returnString = collectibleSponsor.updateCollectibleSponsorByCollectibleSponsorId(event)

    return returnString
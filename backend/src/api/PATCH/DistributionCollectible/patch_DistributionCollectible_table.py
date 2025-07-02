import api.PATCH.DistributionCollectible.patch_DistributionCollectible_functions as distributionCollectibleFunctions
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_DistributionCollectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    DistributionCollectible_Path = API_PATHS_PATCH['DistributionCollectible']

    if raw_path == DistributionCollectible_Path['updateDistributionCollectibleByDistributionCollectibleId']['path']:
        returnString = distributionCollectibleFunctions.updateDistributionCollectibleByDistributionCollectibleId(event)

    return returnString
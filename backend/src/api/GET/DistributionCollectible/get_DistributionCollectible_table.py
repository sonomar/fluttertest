import api.GET.DistributionCollectible.get_DistributionCollectible_functions as distributionCollectibleFunctions
from api.GET.api_paths_get import API_PATHS_GET

def call_DistributionCollectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    DistributionCollectible_Path = API_PATHS_GET['DistributionCollectible']

    if raw_path == DistributionCollectible_Path['getDistributionCollectibleByDistributionCollectibleId']['path']:
        returnString = distributionCollectibleFunctions.getDistributionCollectibleByDistributionCollectibleId(event)
    elif raw_path == DistributionCollectible_Path['getAllDistributionCollectibles']['path']:
        returnString = distributionCollectibleFunctions.getAllDistributionCollectibles(event)
    elif raw_path == DistributionCollectible_Path['getDistributionCollectiblesByCollectibleId']['path']:
        returnString = distributionCollectibleFunctions.getDistributionCollectiblesByCollectibleId(event)
    elif raw_path == DistributionCollectible_Path['getDistributionCollectiblesByDistributionId']['path']:
        returnString = distributionCollectibleFunctions.getDistributionCollectiblesByDistributionId(event)

    return returnString
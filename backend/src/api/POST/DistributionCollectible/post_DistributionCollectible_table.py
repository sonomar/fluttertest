import api.POST.DistributionCollectible.post_DistributionCollectible_functions as distributionCollectibleFunctions
from api.POST.api_paths_post import API_PATHS_POST

def call_DistributionCollectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    DistributionCollectible_Path = API_PATHS_POST['DistributionCollectible']

    if raw_path == DistributionCollectible_Path['createDistributionCollectible']['path']:
        returnString = distributionCollectibleFunctions.createDistributionCollectible(event)

    return returnString
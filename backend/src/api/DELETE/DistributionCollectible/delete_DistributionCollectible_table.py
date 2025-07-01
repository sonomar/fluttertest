import api.DELETE.DistributionCollectible.delete_DistributionCollectible_functions as distributionCollectibleFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_DistributionCollectible_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    DistributionCollectible_Path = API_PATHS_DELETE['DistributionCollectible']

    if raw_path == DistributionCollectible_Path['deleteDistributionCollectibleByDistributionCollectibleId']['path']:
        returnString = distributionCollectibleFunctions.deleteDistributionCollectibleByDistributionCollectibleId(event)

    return returnString
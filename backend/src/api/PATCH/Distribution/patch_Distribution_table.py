import api.PATCH.Distribution.patch_Distribution_functions as distributionFunctions
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_Distribution_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Distribution_Path = API_PATHS_PATCH['Distribution']

    if raw_path == Distribution_Path['updateDistributionByDistributionId']['path']:
        returnString = distributionFunctions.updateDistributionByDistributionId(event)

    return returnString
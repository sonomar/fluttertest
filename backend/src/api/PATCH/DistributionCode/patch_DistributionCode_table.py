import api.PATCH.DistributionCode.patch_DistributionCode_functions as distributionCodeFunctions
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_DistributionCode_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    DistributionCode_Path = API_PATHS_PATCH['DistributionCode']

    if raw_path == DistributionCode_Path['updateDistributionCodeByDistributionCodeId']['path']:
        returnString = distributionCodeFunctions.updateDistributionCodeByDistributionCodeId(event)

    return returnString
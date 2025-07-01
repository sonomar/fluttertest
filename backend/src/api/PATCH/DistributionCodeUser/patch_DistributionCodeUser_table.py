import api.PATCH.DistributionCodeUser.patch_DistributionCodeUser_functions as distributionCodeUserFunctions
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_DistributionCodeUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    DistributionCodeUser_Path = API_PATHS_PATCH['DistributionCodeUser']

    if raw_path == DistributionCodeUser_Path['updateDistributionCodeUserByDistributionCodeUserId']['path']:
        returnString = distributionCodeUserFunctions.updateDistributionCodeUserByDistributionCodeUserId(event)

    return returnString
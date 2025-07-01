import api.GET.DistributionCodeUser.get_DistributionCodeUser_functions as distributionCodeUserFunctions
from api.GET.api_paths_get import API_PATHS_GET

def call_DistributionCodeUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    DistributionCodeUser_Path = API_PATHS_GET['DistributionCodeUser']

    if raw_path == DistributionCodeUser_Path['getDistributionCodeUserByDistributionCodeUserId']['path']:
        returnString = distributionCodeUserFunctions.getDistributionCodeUserByDistributionCodeUserId(event)
    elif raw_path == DistributionCodeUser_Path['getAllDistributionCodeUsers']['path']:
        returnString = distributionCodeUserFunctions.getAllDistributionCodeUsers(event)

    return returnString
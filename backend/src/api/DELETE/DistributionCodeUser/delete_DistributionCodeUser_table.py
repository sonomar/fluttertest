import api.DELETE.DistributionCodeUser.delete_DistributionCodeUser_functions as distributionCodeUserFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_DistributionCodeUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    DistributionCodeUser_Path = API_PATHS_DELETE['DistributionCodeUser']

    if raw_path == DistributionCodeUser_Path['deleteDistributionCodeUserByDistributionCodeUserId']['path']:
        returnString = distributionCodeUserFunctions.deleteDistributionCodeUserByDistributionCodeUserId(event)

    return returnString
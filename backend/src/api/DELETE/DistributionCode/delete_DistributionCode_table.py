import api.DELETE.DistributionCode.delete_DistributionCode_functions as distributionCodeFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_DistributionCode_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    DistributionCode_Path = API_PATHS_DELETE['DistributionCode']

    if raw_path == DistributionCode_Path['deleteDistributionCodeByDistributionCodeId']['path']:
        returnString = distributionCodeFunctions.deleteDistributionCodeByDistributionCodeId(event)

    return returnString
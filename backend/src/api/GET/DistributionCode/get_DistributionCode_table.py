import api.GET.DistributionCode.get_DistributionCode_functions as distributionCodeFunctions
from api.GET.api_paths_get import API_PATHS_GET

def call_DistributionCode_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    DistributionCode_Path = API_PATHS_GET['DistributionCode']

    if raw_path == DistributionCode_Path['getDistributionCodeByDistributionCodeId']['path']:
        returnString = distributionCodeFunctions.getDistributionCodeByDistributionCodeId(event)
    elif raw_path == DistributionCode_Path['getAllDistributionCodes']['path']:
        returnString = distributionCodeFunctions.getAllDistributionCodes(event)
    elif raw_path == DistributionCode_Path['getDistributionCodesByDistributionId']['path']:
        returnString = distributionCodeFunctions.getDistributionCodesByDistributionId(event)
    elif raw_path == DistributionCode_Path['getDistributionCodeByCode']['path']:
        returnString = distributionCodeFunctions.getDistributionCodeByCode(event)

    return returnString
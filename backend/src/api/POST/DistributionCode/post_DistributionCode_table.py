import api.POST.DistributionCode.post_DistributionCode_functions as distributionCodeFunctions
from api.POST.api_paths_post import API_PATHS_POST

def call_DistributionCode_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    DistributionCode_Path = API_PATHS_POST['DistributionCode']

    if raw_path == DistributionCode_Path['createDistributionCode']['path']:
        returnString = distributionCodeFunctions.createDistributionCode(event)

    return returnString
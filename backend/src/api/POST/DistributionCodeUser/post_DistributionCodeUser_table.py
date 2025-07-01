import api.POST.DistributionCodeUser.post_DistributionCodeUser_functions as distributionCodeUserFunctions
from api.POST.api_paths_post import API_PATHS_POST

def call_DistributionCodeUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    DistributionCodeUser_Path = API_PATHS_POST['DistributionCodeUser']

    if raw_path == DistributionCodeUser_Path['createDistributionCodeUser']['path']:
        returnString = distributionCodeUserFunctions.createDistributionCodeUser(event)

    return returnString
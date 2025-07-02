import api.GET.Distribution.get_Distribution_functions as distributionFunctions
from api.GET.api_paths_get import API_PATHS_GET

def call_Distribution_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Distribution_Path = API_PATHS_GET['Distribution']

    if raw_path == Distribution_Path['getDistributionByDistributionId']['path']:
        returnString = distributionFunctions.getDistributionByDistributionId(event)
    elif raw_path == Distribution_Path['getAllDistributions']['path']:
        returnString = distributionFunctions.getAllDistributions(event)
    elif raw_path == Distribution_Path['getDistributionsByProjectId']['path']:
        returnString = distributionFunctions.getDistributionsByProjectId(event)

    return returnString
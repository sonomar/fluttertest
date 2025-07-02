import api.DELETE.Distribution.delete_Distribution_functions as distributionFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_Distribution_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Distribution_Path = API_PATHS_DELETE['Distribution']

    if raw_path == Distribution_Path['deleteDistributionByDistributionId']['path']:
        returnString = distributionFunctions.deleteDistributionByDistributionId(event)

    return returnString
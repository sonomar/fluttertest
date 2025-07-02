import api.POST.Distribution.post_Distribution_functions as distributionFunctions
from api.POST.api_paths_post import API_PATHS_POST

def call_Distribution_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Distribution_Path = API_PATHS_POST['Distribution']

    if raw_path == Distribution_Path['createDistribution']['path']:
        returnString = distributionFunctions.createDistribution(event)

    return returnString
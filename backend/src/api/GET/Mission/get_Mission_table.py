import api.GET.Mission.get_Mission_functions as mission
from api.GET.api_paths_get import API_PATHS_GET

def call_Mission_function(raw_path, event):

    returnString = 'Invalid Function Call'
    Mission_Path = API_PATHS_GET['Mission']

    ## Mission
    if raw_path == Mission_Path['getMissionByMissionId']['path']:
        returnString = mission.getMissionByMissionId(event)

    elif raw_path == Mission_Path['getMissionByTitle']['path']:
        returnString = mission.getMissionByTitle(event)
    
    return returnString
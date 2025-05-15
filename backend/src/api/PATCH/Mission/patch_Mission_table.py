import api.PATCH.Mission.patch_Mission_functions as mission
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_Mission_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Mission_Path = API_PATHS_PATCH['Mission']

    ## Mission
    if raw_path == Mission_Path['updateMissionByMissionId']['path']:
        returnString = mission.updateMissionByMissionId(event)

    return returnString
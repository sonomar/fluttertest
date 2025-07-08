import api.PATCH.MissionType.patch_MissionType_functions as missionTypeFunctions
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_MissionType_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    MissionType_Path = API_PATHS_PATCH['MissionType']

    if raw_path == MissionType_Path['updateMissionTypeByMissionTypeId']['path']:
        returnString = missionTypeFunctions.updateMissionTypeByMissionTypeId(event)

    return returnString
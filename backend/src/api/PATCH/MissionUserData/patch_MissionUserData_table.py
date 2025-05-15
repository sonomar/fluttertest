import api.PATCH.MissionUserData.patch_MissionUserData_functions as missionUserData
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_MissionUserData_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    MissionUserData_Path = API_PATHS_PATCH['MissionUserData']

    ## MissionUserData
    if raw_path == MissionUserData_Path['updateMissionUserDataByMissionUserDataId']['path']:
        returnString = missionUserData.updateMissionUserDataByMissionUserDataId(event)

    return returnString
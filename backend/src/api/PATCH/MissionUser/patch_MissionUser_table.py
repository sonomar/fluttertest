import api.PATCH.MissionUser.patch_MissionUser_functions as missionUser
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_MissionUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    MissionUser_Path = API_PATHS_PATCH['MissionUser']

    ## MissionUser
    if raw_path == MissionUser_Path['updateMissionUserByMissionUserId']['path']:
        returnString = missionUser.updateMissionUserByMissionUserId(event)

    return returnString
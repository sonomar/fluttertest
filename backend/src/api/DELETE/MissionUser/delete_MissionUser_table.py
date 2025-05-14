import api.DELETE.MissionUser.delete_MissionUser_functions as missionUserFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_MissionUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    MissionUser_Path = API_PATHS_DELETE['MissionUser']

    ## MissionUser
    if raw_path == MissionUser_Path['deleteMissionUserByMissionUserId']['path']:
        returnString = missionUserFunctions.deleteMissionUserByMissionUserId(event)

    return returnString
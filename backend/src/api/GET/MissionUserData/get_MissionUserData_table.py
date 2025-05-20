import api.GET.MissionUserData.get_MissionUserData_functions as missionUserData
from api.GET.api_paths_get import API_PATHS_GET

def call_MissionUserData_function(raw_path, event):

    returnString = 'Invalid Function Call'
    MissionUserData_Path = API_PATHS_GET['MissionUserData']

    ## MissionUserData
    if raw_path == MissionUserData_Path['getMissionUserDatasByChallengeUserId']['path']:
        returnString = missionUserData.getMissionUserDatasByChallengeUserId(event)

    elif raw_path == MissionUserData_Path['getMissionUserDatasByUserId']['path']:
        returnString = missionUserData.getMissionUserDatasByUserId(event)

    elif raw_path == MissionUserData_Path['getMissionUserDatasByChallengeId']['path']:
        returnString = missionUserData.getMissionUserDatasByChallengeId(event)
    
    return returnString
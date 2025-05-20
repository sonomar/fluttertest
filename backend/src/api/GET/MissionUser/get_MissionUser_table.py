import api.GET.MissionUser.get_MissionUser_functions as missionUser
from api.GET.api_paths_get import API_PATHS_GET

def call_MissionUser_function(raw_path, event):

    returnString = 'Invalid Function Call'
    MissionUser_Path = API_PATHS_GET['MissionUser']

    ## MissionUser
    if raw_path == MissionUser_Path['getMissionUsersByUserId']['path']:
        returnString = missionUser.getMissionUsersByUserId(event)

    elif raw_path == MissionUser_Path['getMissionUsersByChallengeId']['path']:
        returnString = missionUser.getMissionUsersByChallengeId(event)

    elif raw_path == MissionUser_Path['getMissionUsersByCompleted']['path']:
        returnString = missionUser.getMissionUsersByCompleted(event)
    
    return returnString
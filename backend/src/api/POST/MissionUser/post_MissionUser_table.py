import api.POST.MissionUser.post_MissionUser_functions as missionUser
from api.POST.api_paths_post import API_PATHS_POST

def call_MissionUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    MissionUser_Path = API_PATHS_POST['MissionUser']

    ## MissionUser
    if raw_path == MissionUser_Path['createMissionUser']['path']:
        returnString = missionUser.create_mission_user(event)

    return returnString
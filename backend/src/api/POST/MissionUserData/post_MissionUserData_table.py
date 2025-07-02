import api.POST.MissionUserData.post_MissionUserData_functions as missionUserData
from api.POST.api_paths_post import API_PATHS_POST

def call_MissionUserData_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    MissionUserData_Path = API_PATHS_POST['MissionUserData']

    ## MissionUserData
    if raw_path == MissionUserData_Path['createMissionUserData']['path']:
        returnString = missionUserData.createMissionUserData(event)

    return returnString
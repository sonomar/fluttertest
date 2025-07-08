import api.POST.MissionType.post_MissionType_functions as missionTypeFunctions
from api.POST.api_paths_post import API_PATHS_POST

def call_MissionType_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    MissionType_Path = API_PATHS_POST['MissionType']

    if raw_path == MissionType_Path['createMissionType']['path']:
        returnString = missionTypeFunctions.createMissionType(event)

    return returnString
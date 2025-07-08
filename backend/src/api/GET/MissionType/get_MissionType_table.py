import api.GET.MissionType.get_MissionType_functions as missionTypeFunctions
from api.GET.api_paths_get import API_PATHS_GET

def call_MissionType_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    MissionType_Path = API_PATHS_GET['MissionType']

    if raw_path == MissionType_Path['getMissionTypeByMissionTypeId']['path']:
        returnString = missionTypeFunctions.getMissionTypeByMissionTypeId(event)
    elif raw_path == MissionType_Path['getAllMissionTypes']['path']:
        returnString = missionTypeFunctions.getAllMissionTypes(event)

    return returnString
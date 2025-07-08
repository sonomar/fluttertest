import api.DELETE.MissionType.delete_MissionType_functions as missionTypeFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_MissionType_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    MissionType_Path = API_PATHS_DELETE['MissionType']

    if raw_path == MissionType_Path['deleteMissionTypeByMissionTypeId']['path']:
        returnString = missionTypeFunctions.deleteMissionTypeByMissionTypeId(event)

    return returnString
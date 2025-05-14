import api.DELETE.MissionUserData.delete_MissionUserData_functions as missionUserDataFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_MissionUserData_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    MissionUserData_Path = API_PATHS_DELETE['MissionUserData']

    ## MissionUserData
    if raw_path == MissionUserData_Path['deleteMissionUserDataByMissionUserDataId']['path']:
        returnString = missionUserDataFunctions.deleteMissionUserDataByMissionUserDataId(event)

    return returnString
import api.DELETE.Mission.delete_Mission_functions as missionFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_Mission_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Mission_Path = API_PATHS_DELETE['Mission']

    ## Mission
    if raw_path == Mission_Path['deleteMissionByMissionId']['path']:
        returnString = missionFunctions.deleteMissionByMissionId(event)

    return returnString
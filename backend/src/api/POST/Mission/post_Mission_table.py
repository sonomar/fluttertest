import api.POST.Mission.post_Mission_functions as mission
from api.POST.api_paths_post import API_PATHS_POST

def call_Mission_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Mission_Path = API_PATHS_POST['Mission']

    ## Mission
    if raw_path == Mission_Path['createMission']['path']:
        returnString = mission.create_mission(event)

    return returnString
import api.DELETE.Project.delete_Project_functions as projectFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_Project_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Project_Path = API_PATHS_DELETE['Project']

    ## Project
    if raw_path == Project_Path['deleteProjectByProjectId']['path']:
        returnString = projectFunctions.deleteProjectByProjectId(event)

    return returnString
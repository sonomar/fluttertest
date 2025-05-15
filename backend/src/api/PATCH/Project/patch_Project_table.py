import api.PATCH.Project.patch_Project_functions as project
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_Project_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Project_Path = API_PATHS_PATCH['Project']

    ## Project
    if raw_path == Project_Path['updateProjectByProjectId']['path']:
        returnString = project.updateProjectByProjectId(event)

    return returnString
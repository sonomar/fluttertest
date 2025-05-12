import api.GET.Project.get_Project_functions as project
from api.GET.api_paths_get import API_PATHS_GET

def call_Project_function(raw_path, event):

    returnString = 'Invalid Function Call'
    Project_Path = API_PATHS_GET['Project']

    ## Project
    if raw_path == Project_Path['getProjectByProjectId']:
        returnString = project.getProjectByProjectId(event)

    return returnString
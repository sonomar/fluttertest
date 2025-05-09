import api.GET.Project.get_Project_functions as project
import api.GET.api_path_get as api_path_get

def call_Project_function(raw_path, event):

    returnString = 'Invalid Function Call'

    ## Project
    if raw_path == api_path_get.GET_RAW_PATH_getProjectByProjectId:
        returnString = project.getProjectByProjectId(event)

    return returnString
import api.POST.Project.post_Project_functions as project
from api.POST.api_paths_post import API_PATHS_POST

def call_Project_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Project_Path = API_PATHS_POST['Project']

    ## Project
    if raw_path == Project_Path['createProject']['path']:
        returnString = project.createProject(event)

    return returnString
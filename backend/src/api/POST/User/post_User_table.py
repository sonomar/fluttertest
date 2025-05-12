import api.POST.User.post_User_functions as user
from api.POST.api_paths_post import API_PATHS_POST

def call_User_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    User_Path = API_PATHS_POST['User']

    ## User
    if raw_path == User_Path['createUser']['path']:
        returnString = user.create_user(event)

    return returnString
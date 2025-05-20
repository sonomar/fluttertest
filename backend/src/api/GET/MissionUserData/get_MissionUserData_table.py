import api.GET.User.get_User_functions as user
from api.GET.api_paths_get import API_PATHS_GET

def call_User_function(raw_path, event):

    returnString = 'Invalid Function Call'
    User_Path = API_PATHS_GET['User']

    ## User
    if raw_path == User_Path['getUserByUserId']['path']:
        returnString = user.getUserByUserId(event)

    elif raw_path == User_Path['getUserByEmail']['path']:
        returnString = user.getUserByEmail(event)

    elif raw_path == User_Path['getUserByUsername']['path']:
        returnString = user.getUserByUsername(event)

    elif raw_path == User_Path['getUsersByLastLoggedIn']['path']:
        returnString = user.getUsersByLastLoggedIn(event)
    
    return returnString
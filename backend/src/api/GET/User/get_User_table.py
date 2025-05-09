import api.GET.User.get_User_functions as user
import api.GET.api_path_get as api_path_get

def call_User_function(raw_path, event):

    returnString = 'Invalid Function Call'

    ## User
    if raw_path == api_path_get.GET_RAW_PATH_getUserByUserId:
        returnString = user.getUserByUserId(event)

    elif raw_path == api_path_get.GET_RAW_PATH_getUserByEmail:
        returnString = user.getUserByEmail(event)

    elif raw_path == api_path_get.GET_RAW_PATH_getUserByUsername:
        returnString = user.getUserByUsername(event)

    elif raw_path == api_path_get.GET_RAW_PATH_getUsersByLastLoggedIn:
        returnString = user.getUsersByLastLoggedIn(event)
    
    return returnString
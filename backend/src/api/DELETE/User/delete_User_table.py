import api.DELETE.User.delete_User_functions as user
import api.DELETE.api_path_delete as api_path_delete

def call_User_function(raw_path, event):
    
    returnString = 'Invalid Function Call'

    ## User
    if raw_path == api_path_delete.DELETE_RAW_PATH_deleteUserByUserId:
        returnString = user.deleteUserByUserId(event)

    return returnString
import api.PATCH.User.patch_User_functions as user
import api.PATCH.api_path_patch as api_path_patch

def call_User_function(raw_path, event):
    
    returnString = 'Invalid Function Call'

    ## User
    if raw_path == api_path_patch.UPDATE_RAW_PATH_updateUserByUserId:
        returnString = user.updateUserByUserId(event)

    elif raw_path == api_path_patch.UPDATE_RAW_PATH_updateUserByUserName:
        returnString = user.updateUserByUsername(event)

    return returnString
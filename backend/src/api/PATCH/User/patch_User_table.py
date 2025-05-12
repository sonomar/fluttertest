import api.PATCH.User.patch_User_functions as user
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_User_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    User_Path = API_PATHS_PATCH['User']

    print(User_Path['updateUserByUserId']['path'])

    ## User
    if raw_path == User_Path['updateUserByUserId']['path']:
        returnString = user.updateUserByUserId(event)

    elif raw_path == User_Path['updateUserByUsername']['path']:
        returnString = user.updateUserByUsername(event)

    return returnString
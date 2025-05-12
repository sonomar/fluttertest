import api.DELETE.User.delete_User_functions as user
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_User_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    User_Path = API_PATHS_DELETE['User']

    ## User
    if raw_path == User_Path['deleteUserByUserId']['path']:
        returnString = user.deleteUserByUserId(event)

    return returnString
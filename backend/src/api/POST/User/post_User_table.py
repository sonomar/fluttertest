import api.POST.User.post_User_functions as user
import api.POST.api_path_post as api_path_post

def call_User_function(raw_path, event):
    
    returnString = 'Invalid Function Call'

    ## User
    if raw_path == api_path_post.CREATE_RAW_PATH_createUser:
        returnString = user.create_user(event)

    return returnString
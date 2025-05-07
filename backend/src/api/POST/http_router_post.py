import api.POST.api_path_post as api_path_post
from tools.prod.prodTools import split_string
import api.POST.User.post_User_table as user

def http_router_post(event):
    
    raw_path = split_string(f"{event['rawPath']}")
    returnString = 'Invalid Function Call'

    ##User
    if raw_path == api_path_post.CREATE_RAW_PATH_addUser:
        returnString = user.addUser(event)
    
    return returnString
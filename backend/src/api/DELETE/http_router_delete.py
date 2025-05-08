import api.DELETE.api_path_delete as api_path_delete
from tools.prod.prodTools import split_string
import api.DELETE.User.delete_User_table as user

def http_router_delete(event):
    
    raw_path = split_string(f"{event['rawPath']}")
    returnString = 'Invalid Function Call'
    
    ## User
    if raw_path == api_path_delete.DELETE_RAW_PATH_deleteUserByUserId:
        returnString = user.deleteUserByUserId(event)

    return returnString
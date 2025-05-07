import api.PATCH.api_path_patch as api_path_patch
from tools.prod.prodTools import split_string
import api.PATCH.User.patch_User_table as user

def http_router_patch(event):
    
    raw_path = split_string(f"{event['rawPath']}")
    returnString = 'Invalid Function Call'

    ## User
    if raw_path == api_path_patch.UPDATE_RAW_PATH_updateUserByUserId:
        returnString = user.updateUserByUserId(event)

    elif raw_path == api_path_patch.UPDATE_RAW_PATH_updateUserByUserName:
        returnString = user.updateUserByUsername(event)
        
    return returnString
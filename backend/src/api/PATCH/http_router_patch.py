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

    # elif raw_path == api_path_patch.UPDATE_RAW_PATH_updateActiveByUserId:
    #     returnString = user.updateActiveByUserId(event)

    # elif raw_path == api_path_patch.UPDATE_RAW_PATH_updateEmailByUserId:
    #     returnString = user.updateEmailByUserId(event)

    # elif raw_path == api_path_patch.UPDATE_RAW_PATH_updateUserRankByUserId:
    #     returnString = user.updateUserRankByUserId(event)

    # elif raw_path == api_path_patch.UPDATE_RAW_PATH_updateUsernameByUserId:
    #     returnString = user.updateUsernameByUserId(event)

    # elif raw_path == api_path_patch.UPDATE_RAW_PATH_updatePasswordHashedByUserId:
    #     returnString = user.updatePasswordHashedByUserId(event)

    # elif raw_path == api_path_patch.UPDATE_RAW_PATH_updateProfileImgByUserId:
    #     returnString = user.updateProfileImgByUserId(event)
        
    return returnString
##User
#UPDATE_RAW_PATH_updateUserByUserId = '/updateUserByUserId'
#UPDATE_RAW_PATH_updateUserByUserName = '/updateUserByUsername'
# UPDATE_RAW_PATH_updateActiveByUserId = '/updateActiveByUserId'
# UPDATE_RAW_PATH_updateEmailByUserId = '/updateEmailByUserId'
# UPDATE_RAW_PATH_updateUserRankByUserId = '/updateUserRankByUserId'
# UPDATE_RAW_PATH_updateUsernameByUserId = '/updateUsernameByUserId'
# UPDATE_RAW_PATH_updatePasswordHashedByUserId = '/updatePasswordHashedByUserId'
# UPDATE_RAW_PATH_updateProfileImgByUserId = '/updateProfileImgByUserId'

from api.table import *

API_PATHS_PATCH = {
    User_table: {
        "updateUserByUserId": {
            "path": "/updateUserByUserId",
            "active": True,
            "input": {"userId": "string"},
            "output": {"user": {"id": "string", "username": "string", "email": "string"}}
        },
        "updateUserByUsername": {
            "path": "/updateUserByUsername",
            "active": True,
            "input": {"userId": "string"},
            "output": {"user": {"id": "string", "username": "string", "email": "string"}}
        }
    }
}

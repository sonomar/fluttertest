##User
#UPDATE_RAW_PATH_updateUserByUserId = '/updateUserByUserId'
#UPDATE_RAW_PATH_updateUserByUserName = '/updateUserByUsername'
# UPDATE_RAW_PATH_updateActiveByUserId = '/updateActiveByUserId'
# UPDATE_RAW_PATH_updateEmailByUserId = '/updateEmailByUserId'
# UPDATE_RAW_PATH_updateUserRankByUserId = '/updateUserRankByUserId'
# UPDATE_RAW_PATH_updateUsernameByUserId = '/updateUsernameByUserId'
# UPDATE_RAW_PATH_updatePasswordHashedByUserId = '/updatePasswordHashedByUserId'
# UPDATE_RAW_PATH_updateProfileImgByUserId = '/updateProfileImgByUserId'

# src/api/PATCH/api_path_patch.py

from api.table import *
from database.schema.PATCH.User.user_schema import UserResponse # Import schemas
# Import the modules containing your refactored PATCH handler functions
import database.CRUD.PATCH.User.patch_User_CRUD_functions as UserPATCHFunctions
# ... import other PATCH function modules

API_PATHS_PATCH = {
    User_table: {
        "updateUserByUserId": {
            "path": "/updateUserByUserId", # Assuming userId becomes a path param
            "active": True,
            "handler": UserPATCHFunctions.updateUserByUserId, # <-- Reference
            "response_model": UserResponse # Or maybe a confirmation message schema
             # Input body schema (UserUpdate) and Path param (userId) are in handler signature
        },
         # Add other patch functions once refactored
         "updateUserByUsername": {
            "path": "/updateUserByUsername", # You might want to change this pattern
            "active": True,
            "handler": UserPATCHFunctions.updateUserByUsername, # <-- Reference
            "response_model": UserResponse # Or confirmation
             # Input body schema is in handler signature
        }
    }
    # Add entries for other tables
}

# Keep old variables for temporary compatibility
# UPDATE_RAW_PATH_updateUserByUserId = '/updateUserByUserId'
# UPDATE_RAW_PATH_updateUserByUserName = '/updateUserByUsername'

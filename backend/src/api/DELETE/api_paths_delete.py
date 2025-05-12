# src/api/DELETE/api_path_delete.py
from api.table import *
from typing import Dict
#from database.schema import schemas # Import schemas
# Import the modules containing your refactored DELETE handler functions
import database.CRUD.DELETE.User.delete_User_CRUD_functions as UserDELETEFunctions
# ... import other DELETE function modules

API_PATHS_DELETE = {
    User_table: {
        "deleteUserByUserId": {
            "path": "/deleteUserByUserId", # Assuming userId becomes a path param
            "active": True,
            "handler": UserDELETEFunctions.deleteUserByUserId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    }
    # Add entries for other tables
}

# Keep old variables for temporary compatibility
# DELETE_RAW_PATH_deleteUserByUserId = '/deleteUserByUserId'
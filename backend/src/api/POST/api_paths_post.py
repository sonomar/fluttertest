# src/api/POST/api_path_post.py
from api.table import *
from database.schema.POST.User.user_schema import UserResponse# Import schemas
# Import the modules containing your refactored POST handler functions
import database.CRUD.POST.User.post_User_CRUD_functions as UserPOSTFunctions
# ... import other POST function modules

# Using a dictionary structure similar to GET paths for consistency
API_PATHS_POST = {
    User_table: {
        "createUser": { # Use a descriptive name for the endpoint
            "path": "/createUser", # The path suffix
            "active": True,
            "handler": UserPOSTFunctions.create_user, # <-- Reference the function
            "response_model": UserResponse # <-- Reference the schema
             # Input body schema (UserCreate) is defined in the handler function's signature
        }
        # Add entries for other POST functions once refactored
    }
    # Add entries for other tables (Category, Community, Collectible, etc.)
}

# Keep old variables for temporary compatibility if needed, but they aren't used by the new FastAPI router
# CREATE_RAW_PATH_createUser = '/createUser'
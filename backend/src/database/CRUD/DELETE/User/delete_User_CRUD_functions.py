# src/api/GET/User/get_User_functions.py
# Remove pymysql and old tools imports
# from tools.prod.prodTools import extractData, get_connection # REMOVED


# Import the database session dependency and models/schemas
from fastapi import Depends, HTTPException, status, Path # Added FastAPI dependencies
from sqlalchemy.orm import Session # Added SQLAlchemy Session type
from typing import Dict, Any # Added typing hints

# Import the database session dependency and models
from database.db import get_db # Adjust import path if necessary
from database.models import User # Adjust import path if necessary

# Import custom exceptions
from api.exceptions import NotFoundException # Adjust import path

# --- Refactored Function using SQLAlchemy ORM ---

# Make function async if using an async driver, otherwise sync is fine with Depends
# Keeping sync for now to match previous examples

def deleteUserByUserId(
    userId: int = Path(..., description="ID of the user to delete"), # Get userId from path
    db: Session = Depends(get_db) # Inject database session
) -> Dict[str, str]: # Specify return type hint for a simple success message
    """
    Deletes a user record by userId using SQLAlchemy.
    Requires userId in the path.
    NOTE: This performs a hard delete. ON DELETE CASCADE defined in models.py
    and the database schema will remove related records automatically.
    """
    # 1. Find the user by ID
    # Using db.get() is a simple way to retrieve by primary key
    db_user = db.get(User, userId)
    # Alternatively, using query:
    # db_user = db.query(User).filter(User.userId == userId).first()

    if db_user is None:
        # Raise custom NotFoundException if user does not exist
        raise NotFoundException(detail=f"User with ID {userId} not found")

    # 2. Delete the user object
    try:
        db.delete(db_user) # Mark the object for deletion
        db.commit() # Commit the transaction to execute the delete

        # Return a success message
        return {"message": f"User with ID {userId} deleted successfully"}
    except Exception as e:
        db.rollback() # Ensure rollback on any error
        # Catch potential database errors during deletion
        print(f"Database error deleting user {userId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")


# --- Old call function (Optional - for Transition) ---
# If you kept the old router path, this function would need to be adapted
# or removed if the old router is phased out.
# from api.DELETE.api_path_delete import DELETE_RAW_PATH_deleteUserByUserId # Keep import if needed

# def call_User_function(raw_path, event):
#     """
#     (Optional) Old router function - should be phased out for FastAPI routing.
#     """
#     print(f"Warning: Calling deprecated call_User_function for path {raw_path}")
#     # This function would need to:
#     # 1. Get DB session (manually)
#     # 2. Extract data from 'event' (e.g., userId)
#     # 3. Map raw_path to the new SQLAlchemy function (deleteUserByUserId)
#     # 4. Call the new function: deleteUserByUserId(db=session, userId=...)
#     # 5. Translate result (dict or HTTPException) back to {'statusCode': ..., 'body': ...}
#     return {'statusCode': 501, 'body': 'Not Implemented (Old Router Path)'} # Placeholder

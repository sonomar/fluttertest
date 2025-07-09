# src/api/POST/User/post_User_functions.py
# Remove pymysql and old tools imports
# from tools.prod.prodTools import extractData, get_connection # REMOVED
# import pymysql # REMOVED

# src/api/PATCH/User/patch_User_functions.py

# Remove old tools and pymysql imports
# from tools.prod.prodTools import extractData, get_connection # REMOVED
# import pymysql # REMOVED

from fastapi import Depends, Query, HTTPException, status, Path, Body # Added FastAPI dependencies
from sqlalchemy.orm import Session # Added SQLAlchemy Session type
from sqlalchemy.exc import IntegrityError # Import SQLAlchemy exceptions
from typing import Dict, Any # Added typing hints

# Import the database session dependency and models/schemas
from database.db import get_db # Adjust import path if necessary
from database.models import User, UserTypeEnum # Adjust import path, import UserTypeEnum if using Python Enum
from database.schema.PATCH.User.user_schema import UserUpdate # Adjust import path, import UserUpdate schema
from database.schema.GET.User.user_schema import UserResponse

# Import custom exceptions
from api.exceptions import NotFoundException, ConflictException, BadRequestException # Adjust import path

# --- Refactored Functions using SQLAlchemy ORM ---

# Make functions async if using an async driver, otherwise sync is fine with Depends
# Keeping sync for now to match previous examples

def updateUserByUserId(
    userId: int = Path(..., description="ID of the user to update"), # Get userId from path
    user_update_data: UserUpdate = Body(..., description="Data to update user"), # Get update data from request body
    db: Session = Depends(get_db) # Inject database session
) -> UserResponse: # Specify return schema
    """
    Updates user information based on userId using SQLAlchemy.
    Requires userId in the path and UserUpdate schema in the request body.
    """
    # 1. Find the user by ID
    db_user = db.query(User).filter(User.userId == userId).first()

    if db_user is None:
        # Raise custom NotFoundException if user does not exist
        raise NotFoundException(detail=f"User with ID {userId} not found")

    # 2. Update user attributes based on the provided data
    # Iterate over the fields in the UserUpdate schema that are not None
    update_data = user_update_data.model_dump(exclude_unset=True) # Use model_dump to get dictionary, exclude unset fields

    # Handle specific fields that might need conversion or special logic
    #if 'userType' in update_data and update_data['userType'] is not None:
        # If using Python Enum for userType in model, convert string input to Enum member
    #    try:
    #        update_data['userType'] = UserTypeEnum(update_data['userType'])
    #    except ValueError:
    #        raise BadRequestException(detail=f"Invalid userType value: {update_data['userType']}")

    for field, value in update_data.items():
        # Check if the attribute exists on the model before setting
        if hasattr(db_user, field):
            setattr(db_user, field, value)
        else:
             # Optional: Log a warning if a field in the schema doesn't match the model
             print(f"Warning: Field '{field}' in update data does not exist on User model.")


    # 3. Commit changes
    try:
        db.commit() # Commit the transaction
        db.refresh(db_user) # Refresh the instance to get updated values (like updatedDt)

        # Return the updated SQLAlchemy model instance
        return db_user
    except IntegrityError as e:
         db.rollback() # Rollback the session on error
         # Handle unique constraint violation (email or username)
         error_message = str(e)
         print(f"Integrity error updating user {userId}: {error_message}")

         if 'Duplicate entry' in error_message:
             if "'email'" in error_message:
                 raise ConflictException(detail=f"Email address already exists.")
             elif "'username'" in error_message:
                 raise ConflictException(detail=f"Username already exists.")
             else:
                  raise ConflictException(detail=f"Duplicate entry error: {error_message}")
         else:
              # Handle other integrity errors
              raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback() # Ensure rollback on any other error
        # Catch other potential DB errors
        print(f"Database error updating user {userId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")


# Note: Updating by username is less common and can be problematic if usernames change.
# It's generally better to update by a stable identifier like userId.
# However, if required, here's how you could refactor updateUserByUsername.
# This assumes you provide the *current* username to identify the user
# and the *new* username (and potentially other fields) in the body.

def updateUserByUsername(
    current_username: str = Path(..., description="Current username of the user to update"), # Get current username from query
    user_update_data: UserUpdate = Body(..., description="Data to update user"), # Get update data from request body
    db: Session = Depends(get_db) # Inject database session
) -> UserResponse: # Specify return schema
    """
    Updates user information based on username using SQLAlchemy.
    Requires current username in the query parameters and UserUpdate schema in the request body.
    NOTE: Updating by ID is generally preferred as usernames can change.
    """
    # 1. Find the user by current username
    db_user = db.query(User).filter(User.username == current_username).first()

    if db_user is None:
        # Raise custom NotFoundException if user does not exist
        raise NotFoundException(detail=f"User with username '{current_username}' not found")

    # 2. Update user attributes based on the provided data
    # Iterate over the fields in the UserUpdate schema that are not None
    update_data = user_update_data.model_dump(exclude_unset=True) # Use model_dump

    # Handle specific fields like userType Enum conversion
    if 'userType' in update_data and update_data['userType'] is not None:
        try:
            update_data['userType'] = UserTypeEnum(update_data['userType'])
        except ValueError:
             raise BadRequestException(detail=f"Invalid userType value: {update_data['userType']}")


    for field, value in update_data.items():
        if hasattr(db_user, field):
            setattr(db_user, field, value)
        else:
             print(f"Warning: Field '{field}' in update data does not exist on User model.")


    # 3. Commit changes
    try:
        db.commit() # Commit the transaction
        db.refresh(db_user) # Refresh the instance

        # Return the updated SQLAlchemy model instance
        return db_user
    except IntegrityError as e:
         db.rollback() # Rollback the session on error
         # Handle unique constraint violation (email or username)
         error_message = str(e)
         print(f"Integrity error updating user '{current_username}': {error_message}")

         if 'Duplicate entry' in error_message:
             if "'email'" in error_message:
                 raise ConflictException(detail=f"Email address already exists.")
             elif "'username'" in error_message:
                 raise ConflictException(detail=f"Username already exists.")
             else:
                  raise ConflictException(detail=f"Duplicate entry error: {error_message}")
         else:
              # Handle other integrity errors
              raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback() # Ensure rollback on any other error
        # Catch other potential DB errors
        print(f"Database error updating user '{current_username}': {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")


# --- Old call function (Optional - for Transition) ---
# If you kept the old router path, this function would need to be adapted
# or removed if the old router is phased out.
# from api.PATCH.api_path_patch import UPDATE_RAW_PATH_updateUserByUserId, UPDATE_RAW_PATH_updateUserByUserName # Keep imports if needed

# def call_User_function(raw_path, event):
#     """
#     (Optional) Old router function - should be phased out for FastAPI routing.
#     """
#     print(f"Warning: Calling deprecated call_User_function for path {raw_path}")
#     # This function would need to:
#     # 1. Get DB session (manually)
#     # 2. Extract data from 'event'
#     # 3. Map raw_path to the new SQLAlchemy functions (updateUserByUserId etc.)
#     # 4. Create Pydantic UserUpdate instance from extracted data (handle validation errors)
#     # 5. Extract userId or username from event/data
#     # 6. Call the new function: updateUserByUserId(db=session, userId=..., user_update_data=pydantic_instance)
#     #    or updateUserByUsername(db=session, current_username=..., user_update_data=pydantic_instance)
#     # 7. Translate result (model instance or HTTPException) back to {'statusCode': ..., 'body': ...}
#     return {'statusCode': 501, 'body': 'Not Implemented (Old Router Path)'} # Placeholder

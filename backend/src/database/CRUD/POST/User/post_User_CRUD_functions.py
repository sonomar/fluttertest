# src/api/POST/User/post_User_functions.py
# Remove pymysql and old tools imports
# from tools.prod.prodTools import extractData, get_connection # REMOVED
# import pymysql # REMOVED

from fastapi import Depends, HTTPException, status # Added FastAPI dependencies and exceptions
from sqlalchemy.orm import Session # Added SQLAlchemy Session type
from sqlalchemy.exc import IntegrityError # Import SQLAlchemy exceptions
# from passlib.hash import bcrypt # Example: Import a hashing library


# Import the database session dependency and models/schemas
from database.db import get_db # Adjust import path if necessary
from database.models import User # Adjust import path if necessary
from database.schema.POST.User.user_schema import UserCreate, UserResponse # Adjust import path if necessary

# Import custom exceptions
from api.exceptions import ConflictException, BadRequestException # Adjust import path

# --- Refactored Functions using SQLAlchemy ORM ---

# Make functions async if they involve awaited operations (async driver)
# Keep sync for now
def create_user(
    user: UserCreate, # Expect a Pydantic model as request body
    db: Session = Depends(get_db) # Inject database session
) -> UserResponse: # Specify return schema
    """
    Adds a new user to the database using SQLAlchemy.
    """
    # In a real app, hash the password here!
    # hashed_password = bcrypt.hash(user.password) # Example hashing
    fake_hashed_password = user.passwordHashed + "notreallyhashed" # Placeholder!
    db_user = User(
        email=user.email,
        # Use the hashed password
        passwordHashed=fake_hashed_password, # Use hashed password
        userType=user.userType.value if user.userType is not None else None, # Use .value if using Python Enum
        username=user.username, # Optional fields from schema
        deviceId=user.deviceId,
        # active, createdDt, updatedDt will use server defaults from models
        # userRank, profileImg, authToken, lastLoggedIn are Optional/nullable and default to None
    )

    try:
        db.add(db_user) # Add the new user instance to the session
        db.commit() # Commit the transaction to the database
        db.refresh(db_user) # Refresh the instance to get the new ID (userId) from the database
        # Also refreshes server-set defaults like createdDt, updatedDt

        # Return the SQLAlchemy model instance
        return db_user
    except IntegrityError as e:
         db.rollback() # Rollback the session on error
         # Handle unique constraint violation (email or username)
         # Inspect the SQLAlchemy exception details to identify the violated constraint
         # This part can be database-specific (e.g., MySQL error codes)
         error_message = str(e)
         print(f"Integrity error creating user: {error_message}")

         if 'Duplicate entry' in error_message:
             if "'email'" in error_message: # Check for column name in the error message
                 raise ConflictException(detail=f"Email address '{user.email}' already exists.")
             elif "'username'" in error_message:
                 raise ConflictException(detail=f"Username '{user.username}' already exists.")
             else:
                  raise ConflictException(detail=f"Duplicate entry error: {error_message}")
         else:
              # Handle other integrity errors
              raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback() # Ensure rollback on any other error
        # Catch other potential DB errors
        print(f"Database error creating user: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")

# --- Keep the old call function for potential Lambda compatibility (optional for transition) ---
# from api.POST.api_path_post import CREATE_RAW_PATH_createUser # Keep import if still used by old router path

# def call_User_function(raw_path, event):
#     """
#     (Optional) Old router function - should be phased out for FastAPI routing.
#     """
#     print(f"Warning: Calling deprecated call_User_function for path {raw_path}")
#     # This function would need to:
#     # 1. Get DB session (manually)
#     # 2. Extract data from 'event'
#     # 3. Map raw_path to create_user
#     # 4. Create a Pydantic UserCreate instance from extracted data (handle validation errors)
#     # 5. Call create_user(db=session, user=pydantic_instance)
#     # 6. Translate result (model instance or HTTPException) back to {'statusCode': ..., 'body': ...}
#     return {'statusCode': 501, 'body': 'Not Implemented (Old Router Path)'} # Placeholder
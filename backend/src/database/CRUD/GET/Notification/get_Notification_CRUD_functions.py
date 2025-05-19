# src/api/GET/User/get_User_functions.py
# Remove pymysql and old tools imports
# from tools.prod.prodTools import extractData, get_connection # REMOVED

from fastapi import Depends, Query, HTTPException, status # Added FastAPI dependencies and exceptions
from sqlalchemy.orm import Session # Added SQLAlchemy Session type
from typing import List, Optional # Added typing hints
import datetime # Added datetime for timestamp queries

# Import the database session dependency and models/schemas
from database.db import get_db # Adjust import path if necessary
from database.models import User # Adjust import path if necessary
from database.schema.GET.User.user_schema import UserResponse # Adjust import path if necessary

# Import custom exceptions
from api.exceptions import NotFoundException # Adjust import path

# --- Refactored Functions using SQLAlchemy ORM ---

# Make functions async if they involve awaited operations (though SQLAlchemy sync methods are fine with Depends)
# Let's keep them sync for now, as Depends works with sync generators
# If you move to async drivers (like asyncpg with FastAPI), these would become async def

def getUserByUserId(
    userId: int = Query(..., description="ID of the user to retrieve"), # Define expected query parameter
    db: Session = Depends(get_db) # Inject database session
) -> UserResponse: # Specify return schema for documentation and serialization
    """
    Retrieves a user by their userId using SQLAlchemy.
    """
    # Use SQLAlchemy session query
    db_user = db.query(User).filter(User.userId == userId).first()

    if db_user is None:
        # Raise FastAPI HTTPException for not found
        raise NotFoundException(detail=f"User with ID {userId} not found")

    # Return the SQLAlchemy model instance
    # FastAPI's response_model will automatically serialize it to the UserResponse schema
    return db_user

def getUserByEmail(
    email: str = Query(..., description="Email address of the user to retrieve"),
    db: Session = Depends(get_db)
) -> UserResponse: # Specify return schema
    """
    Retrieves a user by their email address using SQLAlchemy.
    """
    db_user = db.query(User).filter(User.email == email).first()

    if db_user is None:
        raise NotFoundException(detail=f"User with email {email} not found")

    return db_user

def getUserByUsername(
    username: str = Query(..., description="Username of the user to retrieve"),
    db: Session = Depends(get_db)
) -> UserResponse: # Specify return schema
    """
    Retrieves a user by their username using SQLAlchemy.
    """
    db_user = db.query(User).filter(User.username == username).first()

    if db_user is None:
        raise NotFoundException(detail=f"User with username {username} not found")

    return db_user

def getUsersByLastLoggedIn(
    lastLoggedInAfter: datetime.datetime = Query(..., description="Timestamp to retrieve users logged in after"),
    skip: int = Query(0, description="Skip this many items"), # Added pagination
    limit: int = Query(100, description="Limit results to this many items"), # Added pagination
    db: Session = Depends(get_db)
) -> List[UserResponse]: # Specify return schema (list of users)
    """
    Retrieves users who logged in after or at a specific timestamp, with pagination.
    """
    users = db.query(User)\
              .filter(User.lastLoggedIn >= lastLoggedInAfter)\
              .offset(skip)\
              .limit(limit)\
              .all()

    # Return list of SQLAlchemy model instances
    # FastAPI's response_model will serialize each item in the list
    return users

# --- Keep the old call function for potential Lambda compatibility (optional for transition) ---
# If you fully switch to Mangum + FastAPI routing, you can remove all *_table.py and http_router_*.py files
# and the call_*_function methods.
# For a mixed approach during transition, you might keep these temporarily, but they won't be used by the FastAPI app itself.
# Let's assume for this guide that the FastAPI path *bypasses* these old routers and calls the functions directly.
# The dynamic route generation in main.py will facilitate this direct call.
# So, we can mark the old call_User_function as potentially deprecated or for Lambda fallback only.

# from api.GET.api_paths_get import API_PATHS_GET # Keep import if still used by old router path

# def call_User_function(raw_path, event):
#     """
#     (Optional) Old router function - should be phased out for FastAPI routing.
#     This would need significant refactoring to use the new SQLAlchemy functions.
#     """
#     print(f"Warning: Calling deprecated call_User_function for path {raw_path}")
#     # This function would need to:
#     # 1. Get DB session (manually, not via Depends)
#     # 2. Extract data from 'event' (using extractData or manual parsing)
#     # 3. Map raw_path to the correct new SQLAlchemy function (getUserByUserId etc.)
#     # 4. Call the SQLAlchemy function with extracted data and DB session
#     # 5. Translate the SQLAlchemy function's return (model instance or HTTPException) back to the old {'statusCode': ..., 'body': ...} format.
#     # This is complex and highlights why the FastAPI direct routing is preferred.
#     return {'statusCode': 501, 'body': 'Not Implemented (Old Router Path)'} # Placeholder
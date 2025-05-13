# src/api/GET/Category/get_Category_functions.py
# Remove pymysql and old tools imports
# from tools.prod.prodTools import extractData, get_connection # REMOVED


# Import the database session dependency and models/schemas
from fastapi import Depends, HTTPException, status, Path # Added FastAPI dependencies
from sqlalchemy.orm import Session # Added SQLAlchemy Session type
from typing import Dict # Added typing hints

# Import the database session dependency and models
from database.db import get_db # Adjust import path if necessary
from database.models import Category # Adjust import path if necessary

# Import custom exceptions
from api.exceptions import NotFoundException # Adjust import path

# --- Refactored Function using SQLAlchemy ORM ---

# Make function async if using an async driver, otherwise sync is fine with Depends
# Keeping sync for now to match previous examples

def deleteCategoryByCategoryId(
    categoryId: int = Path(..., description="ID of the category to delete"), # Get categoryId from path
    db: Session = Depends(get_db) # Inject database session
) -> Dict[str, str]: # Specify return type hint for a simple success message
    """
    Deletes a category record by categoryId using SQLAlchemy.
    Requires categoryId in the path.
    NOTE: This performs a hard delete. ON DELETE CASCADE defined in models.py
    and the database schema will remove related records automatically.
    """
    # 1. Find the category by ID
    # Using db.get() is a simple way to retrieve by primary key
    db_category = db.get(Category, categoryId)
    # Alternatively, using query:
    # db_category = db.query(Category).filter(Category.categoryId == categoryId).first()

    if db_category is None:
        # Raise custom NotFoundException if category does not exist
        raise NotFoundException(detail=f"Category with ID {categoryId} not found")

    # 2. Delete the category object
    try:
        db.delete(db_category) # Mark the object for deletion
        db.commit() # Commit the transaction to execute the delete

        # Return a success message
        return {"message": f"Category with ID {categoryId} deleted successfully"}
    except Exception as e:
        db.rollback() # Ensure rollback on any error
        # Catch potential database errors during deletion
        print(f"Database error deleting category {categoryId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")

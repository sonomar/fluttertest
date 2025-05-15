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

# Import the database session dependency and models/schemas
from database.db import get_db # Adjust import path if necessary
from database.models import Category # Adjust import path, import UserTypeEnum if using Python Enum
from database.schema.PATCH.Category.category_schema import CategoryUpdate
from database.schema.GET.Category.category_schema import CategoryResponse # Adjust import path, import UserUpdate schema

# Import custom exceptions
from api.exceptions import NotFoundException, ConflictException, BadRequestException # Adjust import path

# --- Refactored Functions using SQLAlchemy ORM ---

# Make functions async if using an async driver, otherwise sync is fine with Depends
# Keeping sync for now to match previous examples
def updateCategoryByCategoryId(
    categoryId: int = Path(..., description="ID of the category to update"),
    category_update_data: CategoryUpdate = Body(..., description="Data to update category"),
    db: Session = Depends(get_db)
) -> CategoryResponse:
    db_category = db.query(Category).filter(Category.categoryId == categoryId).first()

    if db_category is None:
        raise NotFoundException(detail=f"Category with ID {categoryId} not found")

    update_data = category_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_category, field):
            setattr(db_category, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on Category model.")

    try:
        db.commit()
        db.refresh(db_category)
        return db_category
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating category {categoryId}: {error_message}")
        if 'Duplicate entry' in error_message and "'name'" in error_message:
            raise ConflictException(detail=f"Category name already exists.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating category {categoryId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
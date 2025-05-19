from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Category
from database.schema.POST.Category.category_schema import CategoryCreate
from database.schema.GET.Category.category_schema import CategoryResponse # Updated import
from api.exceptions import ConflictException, BadRequestException

def create_category(
    category: CategoryCreate,
    db: Session = Depends(get_db)
) -> CategoryResponse: # Updated return type
    """
    Adds a new category to the database using SQLAlchemy.
    """
    db_category = Category(
        name=category.name
    )

    try:
        db.add(db_category)
        db.commit()
        db.refresh(db_category)
        return CategoryResponse.model_validate(db_category) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating category: {error_message}")
        if 'Duplicate entry' in error_message and "'name'" in error_message:
            raise ConflictException(detail=f"Category name '{category.name}' already exists.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating category: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
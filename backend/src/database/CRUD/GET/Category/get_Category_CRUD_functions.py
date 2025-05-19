# database/CRUD/GET/Category/get_Category_CRUD_functions.py
from fastapi import Depends, Query
from sqlalchemy.orm import Session

from database.db import get_db
from database.models import Category
from database.schema.GET.Category.category_schema import CategoryResponse
from api.exceptions import NotFoundException

def getCategoryByCategoryId(
    categoryId: int = Query(..., description="ID of the category to retrieve"),
    db: Session = Depends(get_db)
) -> CategoryResponse:
    db_category = db.query(Category).filter(Category.categoryId == categoryId).first()
    if db_category is None:
        raise NotFoundException(detail=f"Category with ID {categoryId} not found")
    return db_category
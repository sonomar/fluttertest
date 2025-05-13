# src/api/GET/Category/get_Category_functions.py
# Remove pymysql and old tools imports
# from tools.prod.prodTools import extractData, get_connection # REMOVED


# Import the database session dependency and models/schemas
from fastapi import Depends, HTTPException, status, Path # Added FastAPI dependencies
from sqlalchemy.orm import Session # Added SQLAlchemy Session type
from typing import Dict # Added typing hints

# Import the database session dependency and models
from database.db import get_db # Adjust import path if necessary
from database.models import UserCollectible # Adjust import path if necessary

# Import custom exceptions
from api.exceptions import NotFoundException # Adjust import path

# --- Refactored Function using SQLAlchemy ORM ---

# Make function async if using an async driver, otherwise sync is fine with Depends
# Keeping sync for now to match previous examples

def deleteUserCollectibleByUserCollectibleId(
    userCollectibleId: int = Path(..., description="ID of the UserCollectible record to delete"),
    db: Session = Depends(get_db)
) -> Dict[str, str]:
    # Assuming 'UserCollectible' maps to the 'UserCollectible' model
    db_user_collectible = db.get(UserCollectible, userCollectibleId)
    if db_user_collectible is None:
        raise NotFoundException(detail=f"UserCollectible record with ID {userCollectibleId} not found")
    try:
        db.delete(db_user_collectible)
        db.commit()
        return {"message": f"UserCollectible record with ID {userCollectibleId} deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
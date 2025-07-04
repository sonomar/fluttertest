import logging
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Collectible
from database.schema.POST.Collectible.collectible_schema import CollectibleCreate
from database.schema.GET.Collectible.collectible_schema import CollectibleResponse
from api.exceptions import BadRequestException

# Use the logging module for better error tracking
logger = logging.getLogger(__name__)

def createCollectible(
    collectible: CollectibleCreate,
    db: Session = Depends(get_db)
) -> CollectibleResponse:
    """
    Adds a new collectible to the database using SQLAlchemy.
    This function now handles all fields from the updated schema.
    """
    # Create the SQLAlchemy model instance directly from the Pydantic schema.
    # This is a cleaner and more maintainable way to ensure all fields,
    # including new ones like 'isOnBlockchain' and 'price', are included.
    db_collectible = Collectible(
        **collectible.model_dump()
    )

    try:
        db.add(db_collectible)
        db.commit()
        db.refresh(db_collectible)
        return CollectibleResponse.model_validate(db_collectible)
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        logger.error(f"Integrity error creating collectible: {error_message}")
        # Add specific checks here if there are unique constraints to handle
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        logger.error(f"An unexpected database error occurred while creating a collectible: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="An unexpected database error occurred.")
import logging
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import UserCollectible
from database.schema.POST.UserCollectible.userCollectible_schema import UserCollectibleCreate
from database.schema.GET.UserCollectible.userCollectible_schema import UserCollectibleResponse
from api.exceptions import ConflictException, BadRequestException

# Use the logging module for better error tracking in production
logger = logging.getLogger(__name__)

def createUserCollectible(
    user_collectible: UserCollectibleCreate,
    db: Session = Depends(get_db)
) -> UserCollectibleResponse:
    """
    Adds a new user collectible entry to the database using SQLAlchemy.
    This function now handles all fields from the updated schema automatically.
    """
    # Create the SQLAlchemy model instance directly from the Pydantic schema.
    # This is a cleaner and more robust way to ensure all fields, including
    # the new 'trade', 'points', and 'qrCode' columns, are included.
    db_user_collectible = UserCollectible(
        **user_collectible.model_dump()
    )

    try:
        db.add(db_user_collectible)
        db.commit()
        db.refresh(db_user_collectible)
        return UserCollectibleResponse.model_validate(db_user_collectible)
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        logger.error(f"Integrity error creating user collectible: {error_message}")
        
        # Checking for the unique constraint name is more reliable
        if 'unique_owner_collectible_mint' in error_message:
            raise ConflictException(detail=f"This user already owns this collectible with the same mint number.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
            
    except Exception as e:
        db.rollback()
        logger.error(f"An unexpected database error occurred while creating a user collectible: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="An unexpected database error occurred.")
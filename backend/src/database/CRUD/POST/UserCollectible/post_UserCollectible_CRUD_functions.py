from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import UserCollectible
from database.schema.POST.UserCollectible.userCollectible_schema import UserCollectibleCreate
# Assuming a GET/UserCollectible/userCollectible_schema.py exists or similar naming
from database.schema.GET.UserCollectible.userCollectible_schema import UserCollectibleResponse # Updated import for response schema
from api.exceptions import ConflictException, BadRequestException

def createUserCollectible(
    user_collectible: UserCollectibleCreate,
    db: Session = Depends(get_db)
) -> UserCollectibleResponse: # Updated return type
    """
    Adds a new user collectible entry to the database using SQLAlchemy.
    """
    db_user_collectible = UserCollectible(
        ownerId=user_collectible.ownerId,
        collectibleId=user_collectible.collectibleId,
        mint=user_collectible.mint,
        previousOwnerId=user_collectible.previousOwnerId,
        lastTransferredDt=user_collectible.lastTransferredDt,
        active=user_collectible.active,
        favorite=user_collectible.favorite
    )

    try:
        db.add(db_user_collectible)
        db.commit()
        db.refresh(db_user_collectible)
        return UserCollectibleResponse.model_validate(db_user_collectible) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating user collectible: {error_message}")
        if 'Duplicate entry' in error_message and 'unique_owner_collectible_mint' in error_message:
            raise ConflictException(detail=f"UserCollectible entry with ownerId '{user_collectible.ownerId}', collectibleId '{user_collectible.collectibleId}', and mint '{user_collectible.mint}' already exists.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating user collectible: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
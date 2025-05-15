from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Dict, Any

from database.db import get_db
from database.models import UserCollectible
from database.schema.PATCH.UserCollectible.userCollectible_schema import UserCollectibleUpdate
from database.schema.GET.UserCollectible.userCollectible_schema import UserCollectibleResponse
from api.exceptions import NotFoundException, ConflictException, BadRequestException

def updateUserCollectibleByUserCollectibleId(
    userCollectibleId: int = Path(..., description="ID of the user collectible record to update"),
    user_collectible_update_data: UserCollectibleUpdate = Body(..., description="Data to update user collectible"),
    db: Session = Depends(get_db)
) -> UserCollectibleResponse:
    db_user_collectible = db.query(UserCollectible).filter(UserCollectible.userCollectibleId == userCollectibleId).first()

    if db_user_collectible is None:
        raise NotFoundException(detail=f"User collectible record with ID {userCollectibleId} not found")

    update_data = user_collectible_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_user_collectible, field):
            setattr(db_user_collectible, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on UserCollectible model.")

    try:
        db.commit()
        db.refresh(db_user_collectible)
        return db_user_collectible
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating user collectible {userCollectibleId}: {error_message}")
        if 'Duplicate entry' in error_message and "'ownerId'" in error_message and "'collectibleId'" in error_message and "'mint'":
            raise ConflictException(detail=f"A collectible with this mint number already exists for this owner.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating user collectible {userCollectibleId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
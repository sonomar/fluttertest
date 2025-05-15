from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Dict, Any

from database.db import get_db
from database.models import Collectible
from database.schema.PATCH.Collectible.collectible_schema import CollectibleUpdate
from database.schema.GET.Collectible.collectible_schema import CollectibleResponse
from api.exceptions import NotFoundException, BadRequestException

def updateCollectibleByCollectibleId(
    collectibleId: int = Path(..., description="ID of the collectible to update"),
    collectible_update_data: CollectibleUpdate = Body(..., description="Data to update collectible"),
    db: Session = Depends(get_db)
) -> CollectibleResponse:
    db_collectible = db.query(Collectible).filter(Collectible.collectibleId == collectibleId).first()

    if db_collectible is None:
        raise NotFoundException(detail=f"Collectible with ID {collectibleId} not found")

    update_data = collectible_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_collectible, field):
            setattr(db_collectible, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on Collectible model.")

    try:
        db.commit()
        db.refresh(db_collectible)
        return db_collectible
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating collectible {collectibleId}: {error_message}")
        # Add specific integrity error handling if needed
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating collectible {collectibleId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
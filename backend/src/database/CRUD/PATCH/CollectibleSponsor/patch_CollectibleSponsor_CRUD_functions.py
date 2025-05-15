from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Dict, Any

from database.db import get_db
from database.models import CollectibleSponsor
from database.schema.PATCH.CollectibleSponsor.collectibleSponsor_schema import CollectibleSponsorUpdate
from database.schema.GET.CollectibleSponsor.collectibleSponsor_schema import CollectibleSponsorResponse
from api.exceptions import NotFoundException, ConflictException, BadRequestException

def updateCollectibleSponsorByCollectibleSponsorId(
    collectibleSponsorId: int = Path(..., description="ID of the collectible sponsor record to update"),
    collectible_sponsor_update_data: CollectibleSponsorUpdate = Body(..., description="Data to update collectible sponsor"),
    db: Session = Depends(get_db)
) -> CollectibleSponsorResponse:
    db_collectible_sponsor = db.query(CollectibleSponsor).filter(CollectibleSponsor.collectibleSponsorId == collectibleSponsorId).first()

    if db_collectible_sponsor is None:
        raise NotFoundException(detail=f"Collectible sponsor record with ID {collectibleSponsorId} not found")

    update_data = collectible_sponsor_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_collectible_sponsor, field):
            setattr(db_collectible_sponsor, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on CollectibleSponsor model.")

    try:
        db.commit()
        db.refresh(db_collectible_sponsor)
        return db_collectible_sponsor
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating collectible sponsor {collectibleSponsorId}: {error_message}")
        if 'Duplicate entry' in error_message and "'collectibleId'" in error_message and "'sponsorId'":
            raise ConflictException(detail=f"This collectible already has this sponsor.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating collectible sponsor {collectibleSponsorId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
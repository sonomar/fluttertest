from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Dict, Any

from database.db import get_db
from database.models import Sponsor
from database.schema.PATCH.Sponsor.sponsor_schema import SponsorUpdate
from database.schema.GET.Sponsor.sponsor_schema import SponsorResponse
from api.exceptions import NotFoundException, ConflictException, BadRequestException

def updateSponsorBySponsorId(
    sponsorId: int = Path(..., description="ID of the sponsor to update"),
    sponsor_update_data: SponsorUpdate = Body(..., description="Data to update sponsor"),
    db: Session = Depends(get_db)
) -> SponsorResponse:
    db_sponsor = db.query(Sponsor).filter(Sponsor.sponsorId == sponsorId).first()

    if db_sponsor is None:
        raise NotFoundException(detail=f"Sponsor with ID {sponsorId} not found")

    update_data = sponsor_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_sponsor, field):
            setattr(db_sponsor, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on Sponsor model.")

    try:
        db.commit()
        db.refresh(db_sponsor)
        return db_sponsor
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating sponsor {sponsorId}: {error_message}")
        if 'Duplicate entry' in error_message and "'name'" in error_message:
            raise ConflictException(detail=f"Sponsor name already exists.")
        elif 'Duplicate entry' in error_message and "'primaryContactEmail'" in error_message:
            raise ConflictException(detail=f"Sponsor primary contact email already exists.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating sponsor {sponsorId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
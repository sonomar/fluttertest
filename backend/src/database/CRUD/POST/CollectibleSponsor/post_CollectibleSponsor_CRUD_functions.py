from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import CollectibleSponsor
from database.schema.POST.CollectibleSponsor.collectibleSponsor_schema import CollectibleSponsorCreate
from database.schema.GET.CollectibleSponsor.collectibleSponsor_schema import CollectibleSponsorResponse # Updated import
from api.exceptions import BadRequestException

def createCollectibleSponsor(
    collectible_sponsor: CollectibleSponsorCreate,
    db: Session = Depends(get_db)
) -> CollectibleSponsorResponse: # Updated return type
    """
    Adds a new collectible sponsor entry to the database using SQLAlchemy.
    """
    db_collectible_sponsor = CollectibleSponsor(
        collectibleId=collectible_sponsor.collectibleId,
        sponsorId=collectible_sponsor.sponsorId,
        sponsorMessage=collectible_sponsor.sponsorMessage,
        active=collectible_sponsor.active
    )

    try:
        db.add(db_collectible_sponsor)
        db.commit()
        db.refresh(db_collectible_sponsor)
        return CollectibleSponsorResponse.model_validate(db_collectible_sponsor) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating collectible sponsor: {error_message}")
        # There is no unique constraint on (collectibleId, sponsorId) in models.py
        # If there should be one, it needs to be added to the model.
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating collectible sponsor: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
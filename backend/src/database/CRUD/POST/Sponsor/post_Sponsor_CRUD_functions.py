from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Sponsor
from database.schema.POST.Sponsor.sponsor_schema import SponsorCreate
# Assuming a GET/Sponsor/sponsor_schema.py exists or similar naming
from database.schema.GET.Sponsor.sponsor_schema import SponsorResponse # Updated import for response schema
from api.exceptions import ConflictException, BadRequestException

def create_sponsor(
    sponsor: SponsorCreate,
    db: Session = Depends(get_db)
) -> SponsorResponse: # Updated return type
    """
    Adds a new sponsor to the database using SQLAlchemy.
    """
    db_sponsor = Sponsor(
        name=sponsor.name,
        organization=sponsor.organization,
        urls=sponsor.urls,
        description=sponsor.description,
        imageRef=sponsor.imageRef,
        vidRef=sponsor.vidRef,
        qrRef=sponsor.qrRef,
        embedRef=sponsor.embedRef,
        sponsorCity=sponsor.sponsorCity,
        sponsorCountry=sponsor.sponsorCountry,
        sponsorZip=sponsor.sponsorZip,
        primaryContactName=sponsor.primaryContactName,
        primaryContactEmail=sponsor.primaryContactEmail,
        primaryContactPhone=sponsor.primaryContactPhone,
        active=sponsor.active
    )

    try:
        db.add(db_sponsor)
        db.commit()
        db.refresh(db_sponsor)
        return SponsorResponse.model_validate(db_sponsor) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating sponsor: {error_message}")
        # Add specific checks if there are unique constraints on sponsor fields
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating sponsor: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
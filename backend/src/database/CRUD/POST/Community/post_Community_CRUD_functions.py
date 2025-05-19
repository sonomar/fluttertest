from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Community
from database.schema.POST.Community.community_schema import CommunityCreate
from database.schema.GET.Community.community_schema import CommunityResponse # Updated import
from api.exceptions import BadRequestException

def create_community(
    community: CommunityCreate,
    db: Session = Depends(get_db)
) -> CommunityResponse: # Updated return type
    """
    Adds a new community to the database using SQLAlchemy.
    """
    db_community = Community(
        title=community.title,
        description=community.description,
        imageRef=community.imageRef,
        vidRef=community.vidRef,
        qrRef=community.qrRef,
        embedRef=community.embedRef,
        active=community.active
    )

    try:
        db.add(db_community)
        db.commit()
        db.refresh(db_community)
        return CommunityResponse.model_validate(db_community) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating community: {error_message}")
        # Add specific checks if there are unique constraints on community fields other than primary key
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating community: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
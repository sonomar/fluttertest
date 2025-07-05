from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import CommunityChallenge
from database.schema.POST.CommunityChallenge.communityChallenge_schema import CommunityChallengeCreate
from database.schema.GET.CommunityChallenge.communityChallenge_schema import CommunityChallengeResponse
from api.exceptions import BadRequestException

def createCommunityChallenge(
    community_challenge: CommunityChallengeCreate,
    db: Session = Depends(get_db)
) -> CommunityChallengeResponse:
    """
    Adds a new community challenge to the database using SQLAlchemy, including all new fields.
    """
    # Create the database model instance directly from the Pydantic schema data
    db_community_challenge = CommunityChallenge(
        **community_challenge.model_dump()
    )

    try:
        db.add(db_community_challenge)
        db.commit()
        db.refresh(db_community_challenge)
        return CommunityChallengeResponse.model_validate(db_community_challenge)
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating community challenge: {error_message}")
        # Add specific checks if there are unique constraints on community challenge fields
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating community challenge: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
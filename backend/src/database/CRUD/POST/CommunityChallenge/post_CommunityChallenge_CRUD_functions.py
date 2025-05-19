from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import CommunityChallenge
from database.schema.POST.CommunityChallenge.communityChallenge_schema import CommunityChallengeCreate
from database.schema.GET.CommunityChallenge.communityChallenge_schema import CommunityChallengeResponse # Updated import
from api.exceptions import ConflictException, BadRequestException

def create_community_challenge(
    community_challenge: CommunityChallengeCreate,
    db: Session = Depends(get_db)
) -> CommunityChallengeResponse: # Updated return type
    """
    Adds a new community challenge to the database using SQLAlchemy.
    """
    db_community_challenge = CommunityChallenge(
        communityId=community_challenge.communityId,
        title=community_challenge.title,
        goal=community_challenge.goal,
        timer=community_challenge.timer,
        description=community_challenge.description,
        reward=community_challenge.reward,
        startDate=community_challenge.startDate,
        endDate=community_challenge.endDate,
        imgRef=community_challenge.imgRef,
        vidRef=community_challenge.vidRef,
        qrRef=community_challenge.qrRef,
        embedRef=community_challenge.embedRef
    )

    try:
        db.add(db_community_challenge)
        db.commit()
        db.refresh(db_community_challenge)
        return CommunityChallengeResponse.model_validate(db_community_challenge) # Updated return statement
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
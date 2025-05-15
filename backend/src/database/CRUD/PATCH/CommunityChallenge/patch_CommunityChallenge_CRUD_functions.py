from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Dict, Any

from database.db import get_db
from database.models import CommunityChallenge
from database.schema.PATCH.CommunityChallenge.communityChallenge_schema import CommunityChallengeUpdate
from database.schema.GET.CommunityChallenge.communityChallenge_schema import CommunityChallengeResponse
from api.exceptions import NotFoundException, ConflictException, BadRequestException

def updateCommunityChallengeByCommunityChallengeId(
    communityChallengeId: int = Path(..., description="ID of the community challenge to update"),
    community_challenge_update_data: CommunityChallengeUpdate = Body(..., description="Data to update community challenge"),
    db: Session = Depends(get_db)
) -> CommunityChallengeResponse:
    db_community_challenge = db.query(CommunityChallenge).filter(CommunityChallenge.communityChallengeId == communityChallengeId).first()

    if db_community_challenge is None:
        raise NotFoundException(detail=f"Community challenge with ID {communityChallengeId} not found")

    update_data = community_challenge_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_community_challenge, field):
            setattr(db_community_challenge, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on CommunityChallenge model.")

    try:
        db.commit()
        db.refresh(db_community_challenge)
        return db_community_challenge
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating community challenge {communityChallengeId}: {error_message}")
        # Add specific integrity error handling if needed
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating community challenge {communityChallengeId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
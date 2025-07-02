from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import CommunityUser
from database.schema.POST.CommunityUser.communityUser_schema import CommunityUserCreate
from database.schema.GET.CommunityUser.communityUser_schema import CommunityUserResponse # Updated import
from api.exceptions import ConflictException, BadRequestException

def createCommunityUser(
    community_user: CommunityUserCreate,
    db: Session = Depends(get_db)
) -> CommunityUserResponse: # Updated return type
    """
    Adds a new community user entry to the database using SQLAlchemy.
    """
    db_community_user = CommunityUser(
        communityId=community_user.communityId,
        memberId=community_user.memberId
    )

    try:
        db.add(db_community_user)
        db.commit()
        db.refresh(db_community_user)
        return CommunityUserResponse.model_validate(db_community_user) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating community user: {error_message}")
        if 'Duplicate entry' in error_message and 'unique_community_member' in error_message:
            raise ConflictException(detail=f"CommunityUser entry for communityId '{community_user.communityId}' and memberId '{community_user.memberId}' already exists.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating community user: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
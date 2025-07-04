import logging
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import CommunityUser
from database.schema.POST.CommunityUser.communityUser_schema import CommunityUserCreate
from database.schema.GET.CommunityUser.communityUser_schema import CommunityUserResponse
from api.exceptions import ConflictException, BadRequestException

# Use the logging module for better error handling in production
logger = logging.getLogger(__name__)

def createCommunityUser(
    community_user: CommunityUserCreate,
    db: Session = Depends(get_db)
) -> CommunityUserResponse:
    """
    Adds a new community user entry to the database using SQLAlchemy.
    This function now handles all fields from the updated schema.
    """
    # Create the SQLAlchemy model instance directly from the validated Pydantic schema.
    # This automatically includes all fields, including the new 'completed' JSON field.
    db_community_user = CommunityUser(
        **community_user.model_dump()
    )

    try:
        db.add(db_community_user)
        db.commit()
        db.refresh(db_community_user)
        return CommunityUserResponse.model_validate(db_community_user)
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        logger.error(f"Integrity error creating community user: {error_message}")
        
        # Checking for the unique constraint name is more reliable
        if 'unique_community_member' in error_message:
            raise ConflictException(detail=f"This user is already a member of community '{community_user.communityId}'.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
            
    except Exception as e:
        db.rollback()
        logger.error(f"An unexpected database error occurred while creating a community user: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="An unexpected database error occurred.")
from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Dict, Any

from database.db import get_db
from database.models import CommunityUser
from database.schema.PATCH.CommunityUser.communityUser_schema import CommunityUserUpdate
from database.schema.GET.CommunityUser.communityUser_schema import CommunityUserResponse
from api.exceptions import NotFoundException, ConflictException, BadRequestException

def updateCommunityUserByCommunityUserId(
    communityUserId: int = Path(..., description="ID of the community user record to update"),
    community_user_update_data: CommunityUserUpdate = Body(..., description="Data to update community user"),
    db: Session = Depends(get_db)
) -> CommunityUserResponse:
    db_community_user = db.query(CommunityUser).filter(CommunityUser.communityUserId == communityUserId).first()

    if db_community_user is None:
        raise NotFoundException(detail=f"Community user record with ID {communityUserId} not found")

    update_data = community_user_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_community_user, field):
            setattr(db_community_user, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on CommunityUser model.")

    try:
        db.commit()
        db.refresh(db_community_user)
        return db_community_user
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating community user {communityUserId}: {error_message}")
        if 'Duplicate entry' in error_message and "'communityId'" in error_message and "'memberId'":
            raise ConflictException(detail=f"User is already a member of this community.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating community user {communityUserId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
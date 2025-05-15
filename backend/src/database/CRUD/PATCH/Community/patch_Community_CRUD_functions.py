from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Community
from database.schema.PATCH.Community.community_schema import CommunityUpdate
from database.schema.GET.Community.community_schema import CommunityResponse
from api.exceptions import NotFoundException, ConflictException, BadRequestException

def updateCommunityByCommunityId(
    communityId: int = Path(..., description="ID of the community to update"),
    community_update_data: CommunityUpdate = Body(..., description="Data to update community"),
    db: Session = Depends(get_db)
) -> CommunityResponse:
    db_community = db.query(Community).filter(Community.communityId == communityId).first()

    if db_community is None:
        raise NotFoundException(detail=f"Community with ID {communityId} not found")

    update_data = community_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_community, field):
            setattr(db_community, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on Community model.")

    try:
        db.commit()
        db.refresh(db_community)
        return db_community
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating community {communityId}: {error_message}")
        if 'Duplicate entry' in error_message and "'title'" in error_message:
            raise ConflictException(detail=f"Community title already exists.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating community {communityId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
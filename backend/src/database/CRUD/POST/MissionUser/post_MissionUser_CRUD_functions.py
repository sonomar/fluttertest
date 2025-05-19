from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import MissionUser
from database.schema.POST.MissionUser.missionUser_schema import MissionUserCreate
from database.schema.GET.MissionUser.missionUser_schema import MissionUserResponse # Updated import
from api.exceptions import ConflictException, BadRequestException

def create_mission_user(
    mission_user: MissionUserCreate,
    db: Session = Depends(get_db)
) -> MissionUserResponse: # Updated return type
    """
    Adds a new mission user entry to the database using SQLAlchemy.
    """
    db_mission_user = MissionUser(
        userId=mission_user.userId,
        missionId=mission_user.missionId,
        progress=mission_user.progress,
        status=mission_user.status,
        completed=mission_user.completed,
        dateCompleted=mission_user.dateCompleted,
        rewardClaimed=mission_user.rewardClaimed
    )

    try:
        db.add(db_mission_user)
        db.commit()
        db.refresh(db_mission_user)
        return MissionUserResponse.model_validate(db_mission_user) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating mission user: {error_message}")
        if 'Duplicate entry' in error_message and 'unique_user_mission' in error_message:
            raise ConflictException(detail=f"MissionUser entry for userId '{mission_user.userId}' and missionId '{mission_user.missionId}' already exists.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating mission user: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
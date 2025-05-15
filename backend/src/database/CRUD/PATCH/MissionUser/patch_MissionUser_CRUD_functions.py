from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import MissionUser
from database.schema.PATCH.MissionUser.missionUser_schema import MissionUserUpdate
from database.schema.GET.MissionUser.missionUser_schema import MissionUserResponse
from api.exceptions import NotFoundException, ConflictException, BadRequestException

def updateMissionUserByMissionUserId(
    missionUserId: int = Path(..., description="ID of the mission user record to update"),
    mission_user_update_data: MissionUserUpdate = Body(..., description="Data to update mission user"),
    db: Session = Depends(get_db)
) -> MissionUserResponse:
    db_mission_user = db.query(MissionUser).filter(MissionUser.missionUserId == missionUserId).first()

    if db_mission_user is None:
        raise NotFoundException(detail=f"Mission user record with ID {missionUserId} not found")

    update_data = mission_user_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_mission_user, field):
            setattr(db_mission_user, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on MissionUser model.")

    try:
        db.commit()
        db.refresh(db_mission_user)
        return db_mission_user
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating mission user {missionUserId}: {error_message}")
        if 'Duplicate entry' in error_message and "'userId'" in error_message and "'missionId'":
            raise ConflictException(detail=f"This user is already participating in this mission.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating mission user {missionUserId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
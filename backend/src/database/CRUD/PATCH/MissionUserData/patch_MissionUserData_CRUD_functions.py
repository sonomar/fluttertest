from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Dict, Any

from database.db import get_db
from database.models import MissionUserData
from database.schema.PATCH.MissionUserData.missionUserData_schema import MissionUserDataUpdate
from database.schema.GET.MissionUserData.missionUserData_schema import MissionUserDataResponse
from api.exceptions import NotFoundException, ConflictException, BadRequestException

def updateMissionUserDataByMissionUserDataId(
    missionUserDataId: int = Path(..., description="ID of the mission user data record to update"),
    mission_user_data_update_data: MissionUserDataUpdate = Body(..., description="Data to update mission user data"),
    db: Session = Depends(get_db)
) -> MissionUserDataResponse:
    db_mission_user_data = db.query(MissionUserData).filter(MissionUserData.missionUserDataId == missionUserDataId).first()

    if db_mission_user_data is None:
        raise NotFoundException(detail=f"Mission user data record with ID {missionUserDataId} not found")

    update_data = mission_user_data_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_mission_user_data, field):
            setattr(db_mission_user_data, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on MissionUserData model.")

    try:
        db.commit()
        db.refresh(db_mission_user_data)
        return db_mission_user_data
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating mission user data {missionUserDataId}: {error_message}")
        # Add specific integrity error handling if needed
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating mission user data {missionUserDataId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
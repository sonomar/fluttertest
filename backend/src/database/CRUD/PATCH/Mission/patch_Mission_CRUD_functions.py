from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Dict, Any

from database.db import get_db
from database.models import Mission
from database.schema.PATCH.Mission.mission_schema import MissionUpdate
from database.schema.GET.Mission.mission_schema import MissionResponse
from api.exceptions import NotFoundException, BadRequestException

def updateMissionByMissionId(
    missionId: int = Path(..., description="ID of the mission to update"),
    mission_update_data: MissionUpdate = Body(..., description="Data to update mission"),
    db: Session = Depends(get_db)
) -> MissionResponse:
    db_mission = db.query(Mission).filter(Mission.missionId == missionId).first()

    if db_mission is None:
        raise NotFoundException(detail=f"Mission with ID {missionId} not found")

    update_data = mission_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_mission, field):
            setattr(db_mission, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on Mission model.")

    try:
        db.commit()
        db.refresh(db_mission)
        return db_mission
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating mission {missionId}: {error_message}")
        # Add specific integrity error handling if needed
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating mission {missionId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
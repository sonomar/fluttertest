from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import MissionType
from database.schema.PATCH.MissionType.missionType_schema import MissionTypeUpdate
from api.exceptions import NotFoundException, BadRequestException, ConflictException

def updateMissionTypeByMissionTypeId(
    missionTypeId: int,
    mission_type: MissionTypeUpdate,
    db: Session = Depends(get_db)
):
    db_mission_type = db.query(MissionType).filter(MissionType.missionTypeId == missionTypeId).first()
    if not db_mission_type:
        raise NotFoundException(detail=f"MissionType with ID {missionTypeId} not found")

    update_data = mission_type.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_mission_type, key, value)

    try:
        db.commit()
        db.refresh(db_mission_type)
        return db_mission_type
    except IntegrityError as e:
        db.rollback()
        if 'Duplicate entry' in str(e) and "'name'" in str(e):
            raise ConflictException(detail=f"MissionType name already exists.")
        raise BadRequestException(detail=f"Database integrity error: {e}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
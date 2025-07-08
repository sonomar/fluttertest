from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import MissionType
from database.schema.POST.MissionType.missionType_schema import MissionTypeCreate
from api.exceptions import ConflictException, BadRequestException

def createMissionType(
    mission_type: MissionTypeCreate,
    db: Session = Depends(get_db)
):
    """
    Adds a new mission type to the database using SQLAlchemy.
    """
    db_mission_type = MissionType(
        name=mission_type.name,
        description=mission_type.description
    )

    try:
        db.add(db_mission_type)
        db.commit()
        db.refresh(db_mission_type)
        return db_mission_type
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        if 'Duplicate entry' in error_message and "'name'" in error_message:
            raise ConflictException(detail=f"MissionType name '{mission_type.name}' already exists.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
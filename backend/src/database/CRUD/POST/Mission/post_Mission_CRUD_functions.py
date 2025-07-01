from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Mission
from database.schema.POST.Mission.mission_schema import MissionCreate
from database.schema.GET.Mission.mission_schema import MissionResponse # Updated import
from api.exceptions import BadRequestException

def createMission(
    mission: MissionCreate,
    db: Session = Depends(get_db)
) -> MissionResponse: # Updated return type
    """
    Adds a new mission to the database using SQLAlchemy.
    """
    db_mission = Mission(
        collectionId=mission.collectionId,
        title=mission.title,
        description=mission.description,
        reward=mission.reward,
        goal=mission.goal,
        timer=mission.timer,
        endDate=mission.endDate,
        imgRef=mission.imgRef,
        vidRef=mission.vidRef,
        qrRef=mission.qrRef,
        embedRef=mission.embedRef
    )

    try:
        db.add(db_mission)
        db.commit()
        db.refresh(db_mission)
        return MissionResponse.model_validate(db_mission) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating mission: {error_message}")
        # Add specific checks if there are unique constraints on mission fields
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating mission: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
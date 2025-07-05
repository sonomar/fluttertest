import logging
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Mission
from database.schema.POST.Mission.mission_schema import MissionCreate
from database.schema.GET.Mission.mission_schema import MissionResponse
from api.exceptions import BadRequestException

# It's best practice to use a logger for application messages and errors
logger = logging.getLogger(__name__)

def createMission(
    mission: MissionCreate,
    db: Session = Depends(get_db)
) -> MissionResponse:
    """
    Adds a new mission to the database using SQLAlchemy.
    This function now handles all fields from the updated schema automatically.
    """
    # Create the SQLAlchemy model instance directly from the validated Pydantic schema.
    # This automatically includes all fields from the schema, such as the new 'rewardId'.
    db_mission = Mission(
        **mission.model_dump()
    )

    try:
        db.add(db_mission)
        db.commit()
        db.refresh(db_mission)
        return MissionResponse.model_validate(db_mission)
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        logger.error(f"Integrity error creating mission: {error_message}")
        # Add specific checks here if there are unique constraints to handle
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        logger.error(f"An unexpected database error occurred while creating a mission: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="An unexpected database error occurred.")
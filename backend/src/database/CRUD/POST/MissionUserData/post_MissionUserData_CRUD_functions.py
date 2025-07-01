from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import MissionUserData
from database.schema.POST.MissionUserData.missionUserData_schema import MissionUserDataCreate
from database.schema.GET.MissionUserData.missionUserData_schema import MissionUserDataResponse # Updated import
from api.exceptions import BadRequestException

def createMissionUserData(
    mission_user_data: MissionUserDataCreate,
    db: Session = Depends(get_db)
) -> MissionUserDataResponse: # Updated return type
    """
    Adds new mission user data entry to the database using SQLAlchemy.
    """
    db_mission_user_data = MissionUserData(
        missionUserId=mission_user_data.missionUserId,
        action=mission_user_data.action,
        status=mission_user_data.status
    )

    try:
        db.add(db_mission_user_data)
        db.commit()
        db.refresh(db_mission_user_data)
        return MissionUserDataResponse.model_validate(db_mission_user_data) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating mission user data: {error_message}")
        # Add specific checks if there are unique constraints on mission user data fields
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating mission user data: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
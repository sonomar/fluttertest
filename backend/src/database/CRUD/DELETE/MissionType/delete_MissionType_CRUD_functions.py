from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session

from database.db import get_db
from database.models import MissionType
from api.exceptions import NotFoundException

def deleteMissionTypeByMissionTypeId(
    missionTypeId: int,
    db: Session = Depends(get_db)
):
    db_mission_type = db.query(MissionType).filter(MissionType.missionTypeId == missionTypeId).first()
    if not db_mission_type:
        raise NotFoundException(detail=f"MissionType with ID {missionTypeId} not found")

    try:
        db.delete(db_mission_type)
        db.commit()
        return {"message": f"MissionType with ID {missionTypeId} deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
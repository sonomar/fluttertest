from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import MissionType
from database.schema.GET.MissionType.missionType_schema import MissionTypeResponse
from api.exceptions import NotFoundException

def getMissionTypeByMissionTypeId(
    missionTypeId: int,
    db: Session = Depends(get_db)
) -> MissionTypeResponse:
    db_mission_type = db.query(MissionType).filter(MissionType.missionTypeId == missionTypeId).first()
    if db_mission_type is None:
        raise NotFoundException(detail=f"MissionType with ID {missionTypeId} not found")
    return db_mission_type

def getAllMissionTypes(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
) -> List[MissionTypeResponse]:
    return db.query(MissionType).offset(skip).limit(limit).all()
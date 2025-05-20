# database/CRUD/GET/Mission/get_Mission_CRUD_functions.py
from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import Mission
from database.schema.GET.Mission.mission_schema import MissionResponse
from api.exceptions import NotFoundException

def getMissionByMissionId(
    missionId: int = Query(..., description="ID of the mission to retrieve"),
    db: Session = Depends(get_db)
) -> MissionResponse:
    db_mission = db.query(Mission).filter(Mission.missionId == missionId).first()
    if db_mission is None:
        raise NotFoundException(detail=f"Mission with ID {missionId} not found")
    return db_mission

def getMissionByTitle(
    title: str = Query(..., description="Title of the mission to retrieve"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[MissionResponse]:
    missions = db.query(Mission).filter(Mission.title.ilike(f"%{title}%")).offset(skip).limit(limit).all()
    return missions
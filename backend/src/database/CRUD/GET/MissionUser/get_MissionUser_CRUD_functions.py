# database/CRUD/GET/MissionUser/get_MissionUser_CRUD_functions.py
from fastapi import Depends, Query, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from database.db import get_db
from database.models import MissionUser
from database.schema.GET.MissionUser.missionUser_schema import MissionUserResponse

def getMissionUsersByUserId(
    userId: int = Query(..., description="ID of the user to retrieve mission user records for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[MissionUserResponse]:
    mission_users = db.query(MissionUser).filter(MissionUser.userId == userId).offset(skip).limit(limit).all()
    return mission_users

def getMissionUsersByChallengeId( # Renamed to missionId based on models.py
    missionId: int = Query(..., description="ID of the mission to retrieve mission user records for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[MissionUserResponse]:
    mission_users = db.query(MissionUser).filter(MissionUser.missionId == missionId).offset(skip).limit(limit).all()
    return mission_users

def getMissionUsersByCompleted(
    completed: bool = Query(..., description="Filter by completed status"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[MissionUserResponse]:
    mission_users = db.query(MissionUser).filter(MissionUser.completed == completed).offset(skip).limit(limit).all()
    return mission_users
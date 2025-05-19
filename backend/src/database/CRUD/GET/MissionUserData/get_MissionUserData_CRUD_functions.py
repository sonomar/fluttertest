# database/CRUD/GET/MissionUserData/get_MissionUserData_CRUD_functions.py
from fastapi import Depends, Query, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from database.db import get_db
from database.models import MissionUserData, MissionUser
from database.schema.GET.MissionUserData.missionUserData_schema import MissionUserDataResponse

def getMissionUserDatasByChallengeUserId( # Renamed to missionUserId based on models.py
    missionUserId: int = Query(..., description="ID of the mission user to retrieve data for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[MissionUserDataResponse]:
    mission_user_data = db.query(MissionUserData).filter(MissionUserData.missionUserId == missionUserId).offset(skip).limit(limit).all()
    return mission_user_data

def getMissionUserDatasByUserId(
    userId: int = Query(..., description="ID of the user to retrieve mission user data for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[MissionUserDataResponse]:
    mission_user_data = db.query(MissionUserData).join(MissionUserData.MissionUser_).filter(MissionUser.userId == userId).offset(skip).limit(limit).all()
    return mission_user_data

def getMissionUserDatasByChallengeId( # Renamed to missionId based on models.py
    missionId: int = Query(..., description="ID of the mission to retrieve mission user data for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[MissionUserDataResponse]:
    mission_user_data = db.query(MissionUserData).join(MissionUserData.MissionUser_).filter(MissionUser.missionId == missionId).offset(skip).limit(limit).all()
    return mission_user_data
from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# --- Mission Schemas ---
class MissionResponse(BaseModel):
    missionId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime
    collectionId: int
    title: str
    description: Optional[str] = None
    reward: Optional[str] = None
    goal: int
    timer: Optional[bool] = False
    endDate: Optional[datetime.datetime] = None
    imgRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None

    class Config:
        from_attributes = True
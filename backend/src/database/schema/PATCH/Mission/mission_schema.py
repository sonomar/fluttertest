from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# --- Mission Schemas ---
class MissionUpdate(BaseModel):
    collectionId: Optional[int] = None
    title: Optional[str] = None
    description: Optional[str] = None
    reward: Optional[str] = None
    goal: Optional[int] = None
    timer: Optional[bool] = None
    endDate: Optional[datetime.datetime] = None
    imgRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
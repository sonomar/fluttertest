from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# --- CommunityChallenge Schemas ---
class CommunityChallengeCreate(BaseModel):
    communityId: int
    title: str
    goal: int
    timer: Optional[bool] = False
    description: Optional[str] = None
    reward: Optional[str] = None
    startDate: Optional[datetime.datetime] = None
    endDate: Optional[datetime.datetime] = None
    imgRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[str] = None
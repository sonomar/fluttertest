from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# --- CommunityChallenge Schemas ---
class CommunityChallengeUpdate(BaseModel):
    communityId: Optional[int] = None
    title: Optional[str] = None
    goal: Optional[int] = None
    timer: Optional[bool] = None
    description: Optional[str] = None
    reward: Optional[str] = None
    startDate: Optional[datetime.datetime] = None
    endDate: Optional[datetime.datetime] = None
    imgRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[str] = None
from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# --- Community Schemas ---
class CommunityResponse(BaseModel):
    communityId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    title: str
    description: Optional[str] = None
    imageRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    active: Optional[bool] = True

    class Config:
        from_attributes = True
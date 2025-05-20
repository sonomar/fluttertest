from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

# --- CommunityChallenge Schemas ---
class CommunityChallengeResponse(BaseModel):
    communityChallengeId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    communityId: int
    title: str
    goal: int
    timer: Optional[bool] = False
    description: Optional[str] = None
    reward: Optional[str] = None
    startDate: Optional[datetime.datetime] = None
    endDate: Optional[datetime.datetime] = None
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None

    class Config:
        from_attributes = True
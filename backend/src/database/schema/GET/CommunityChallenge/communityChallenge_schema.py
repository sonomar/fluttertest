from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

# --- CommunityChallenge Schemas ---
class CommunityChallengeResponse(BaseModel):
    communityChallengeId: int
    communityId: int
    title: Dict[str, str]
    goal: int
    rewardId: Optional[int] = None
    webRef: Optional[Dict[str, Any]] = None
    timer: Optional[bool] = False
    description: Optional[Dict[str, str]] = None
    reward: Optional[Dict[str, str]] = None
    startDate: Optional[datetime.datetime] = None
    endDate: Optional[datetime.datetime] = None
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
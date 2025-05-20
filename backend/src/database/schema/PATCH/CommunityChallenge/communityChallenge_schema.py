from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
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
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
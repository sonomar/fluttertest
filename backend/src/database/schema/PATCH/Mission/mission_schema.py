from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

class MissionUpdate(BaseModel):
    collectionId: Optional[int] = None
    title: Optional[Dict[str, str]] = None
    description: Optional[Dict[str, str]] = None
    reward: Optional[str] = None
    rewardId: Optional[int] = None
    goal: Optional[int] = None
    timer: Optional[bool] = None
    endDate: Optional[datetime.datetime] = None
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
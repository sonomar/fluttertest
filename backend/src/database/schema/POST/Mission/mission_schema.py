from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

class MissionCreate(BaseModel):
    collectionId: int
    missionTypeId: int
    title: Dict[str, str]
    reward: Optional[str] = None
    goal: int
    description: Optional[Dict[str, str]] = None
    rewardId: Optional[int] = None
    timer: Optional[bool] = False
    endDate: Optional[datetime.datetime] = None
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    parameterJson: Optional[Dict[str, Any]] = None
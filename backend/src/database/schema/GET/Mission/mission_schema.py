from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
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
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None

    class Config:
        from_attributes = True
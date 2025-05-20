from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

# --- Community Schemas ---
class CommunityResponse(BaseModel):
    communityId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    title: str
    description: Optional[str] = None
    imageRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    active: Optional[bool] = True

    class Config:
        from_attributes = True
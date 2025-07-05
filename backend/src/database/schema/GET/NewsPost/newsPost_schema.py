from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, Union, List
import datetime

# --- NewsPost Schemas ---
class NewsPostResponse(BaseModel):
    newsPostId: int
    header: Dict[str, str]
    body: Dict[str, str]
    shortBody: Dict[str, str]
    postDate: Optional[datetime.datetime] = None
    type: Optional[str] = None
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    active: Optional[bool] = True
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
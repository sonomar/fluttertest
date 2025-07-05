from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, Union, List
import datetime

# --- NewsPost Schemas ---
class NewsPostCreate(BaseModel):
    header: Dict[str, str]
    body: Dict[str, str]
    shortBody: Dict[str, str]
    postDate: Optional[datetime.datetime] = Field(default_factory=datetime.datetime.utcnow)
    type: Optional[str] = None
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    active: Optional[bool] = True
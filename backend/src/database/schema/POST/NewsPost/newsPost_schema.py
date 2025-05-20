from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, Union, List
import datetime

# --- NewsPost Schemas ---
class NewsPostCreate(BaseModel):
    header: str
    body: str
    shortBody: str
    postDate: Optional[datetime.datetime] = Field(default_factory=datetime.datetime.utcnow) # Use utcnow as default
    type: Optional[str] = None
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    active: Optional[bool] = True
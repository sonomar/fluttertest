from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

# --- NewsPost Schemas ---
class NewsPostUpdate(BaseModel):
    header: Optional[str] = None
    body: Optional[str] = None
    shortBody: Optional[str] = None
    postDate: Optional[datetime.datetime] = None
    type: Optional[str] = None
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    active: Optional[bool] = None
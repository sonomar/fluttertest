from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# --- NewsPost Schemas ---
class NewsPostUpdate(BaseModel):
    header: Optional[str] = None
    body: Optional[str] = None
    shortBody: Optional[str] = None
    postDate: Optional[datetime.datetime] = None
    type: Optional[str] = None
    imgRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    active: Optional[bool] = None
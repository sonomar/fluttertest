from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
import datetime

# --- NewsPost Schemas ---
class NewsPostCreate(BaseModel):
    header: str
    body: str
    shortBody: str
    postDate: Optional[datetime.datetime] = Field(default_factory=datetime.datetime.utcnow) # Use utcnow as default
    type: Optional[str] = None
    imgRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None               
    active: Optional[bool] = True
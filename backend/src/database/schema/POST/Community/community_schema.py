from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# --- Community Schemas ---
class CommunityCreate(BaseModel):
    title: str
    description: Optional[str] = None
    imageRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    active: Optional[bool] = True
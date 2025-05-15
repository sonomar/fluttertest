from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# --- Community Schemas ---
class CommunityUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    imageRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    active: Optional[bool] = None
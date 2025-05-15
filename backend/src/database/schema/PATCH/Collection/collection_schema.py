from pydantic import BaseModel
from typing import Optional, Dict, Any

# --- Collection Schemas ---
class CollectionUpdate(BaseModel):
    communityId: Optional[int] = None
    name: Optional[str] = None
    description: Optional[str] = None
    imageRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    active: Optional[bool] = None
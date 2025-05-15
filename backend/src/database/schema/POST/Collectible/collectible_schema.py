from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# --- Collectible Schemas ---
class CollectibleCreate(BaseModel):
    collectionId: int
    categoryId: int
    projectId: int
    communityId: int
    label: str
    name: str
    description: Optional[str] = None
    imageRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    circulation: Optional[int] = None
    publicationDate: Optional[datetime.datetime] = None
    active: Optional[bool] = True
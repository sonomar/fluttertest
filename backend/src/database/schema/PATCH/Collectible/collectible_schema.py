from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# --- Collectible Schemas ---
class CollectibleUpdate(BaseModel):
     # Inherit base fields and make them optional for updates
     collectionId: Optional[int] = None
     categoryId: Optional[int] = None
     projectId: Optional[int] = None
     communityId: Optional[int] = None
     label: Optional[str] = None
     name: Optional[str] = None
     description: Optional[str] = None
     imageRef: Optional[Dict[str, Any]] = None
     vidRef: Optional[Dict[str, Any]] = None
     qrRef: Optional[Dict[str, Any]] = None
     embedRef: Optional[Dict[str, Any]] = None
     circulation: Optional[int] = None
     publicationDate: Optional[datetime.datetime] = None
     active: Optional[bool] = None
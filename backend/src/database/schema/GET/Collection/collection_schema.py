from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# --- Collection Schemas ---
class CollectionResponse(BaseModel):
    collectionId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    communityId: int # Assuming you pass the communityId when creating/updating a collection
    name: str
    description: Optional[str] = None
    imageRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    active: Optional[bool] = True

    class Config:
        from_attributes = True
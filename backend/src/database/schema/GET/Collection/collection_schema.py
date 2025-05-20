from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

# --- Collection Schemas ---
class CollectionResponse(BaseModel):
    collectionId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    communityId: int # Assuming you pass the communityId when creating/updating a collection
    name: str
    description: Optional[str] = None
    imageRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    active: Optional[bool] = True

    class Config:
        from_attributes = True
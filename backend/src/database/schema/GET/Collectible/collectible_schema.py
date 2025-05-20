from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

# --- Collectible Schemas ---
class CollectibleResponse(BaseModel):
    collectibleId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime
    collectionId: int
    categoryId: int
    projectId: int
    communityId: int
    label: str
    name: str
    description: Optional[str] = None
    imageRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    circulation: Optional[int] = None
    publicationDate: Optional[datetime.datetime] = None
    active: Optional[bool] = True

    class Config:
        from_attributes = True
from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

class CollectibleResponse(BaseModel):
    collectibleId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime
    collectionId: int
    categoryId: int
    projectId: int
    communityId: int
    label: Dict[str, str]
    name: Dict[str, str]
    description: Optional[Dict[str, str]] = None
    imageRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    circulation: Optional[int] = None
    publicationDate: Optional[datetime.datetime] = None
    active: Optional[bool] = True
    isOnBlockchain: Optional[bool] = None
    blockchainCollectibleAddress: Optional[str] = None
    price: Optional[Dict[str, Any]] = None

    class Config:
        from_attributes = True
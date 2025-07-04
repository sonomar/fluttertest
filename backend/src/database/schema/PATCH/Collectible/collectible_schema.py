from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

class CollectibleUpdate(BaseModel):
     collectionId: Optional[int] = None
     categoryId: Optional[int] = None
     projectId: Optional[int] = None
     communityId: Optional[int] = None
     label: Optional[Dict[str, str]] = None
     name: Optional[Dict[str, str]] = None
     description: Optional[Dict[str, str]] = None
     imageRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
     vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
     qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
     embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
     circulation: Optional[int] = None
     publicationDate: Optional[datetime.datetime] = None
     active: Optional[bool] = None
     isOnBlockchain: Optional[bool] = None
     blockchainCollectibleAddress: Optional[str] = None
     price: Optional[Dict[str, Any]] = None
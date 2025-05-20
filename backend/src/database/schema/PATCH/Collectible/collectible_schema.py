from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
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
     imageRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
     vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
     qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
     embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
     circulation: Optional[int] = None
     publicationDate: Optional[datetime.datetime] = None
     active: Optional[bool] = None
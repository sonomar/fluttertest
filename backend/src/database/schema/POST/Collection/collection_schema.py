from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List

class CollectionCreate(BaseModel):
    communityId: int
    projectId: int
    name: Dict[str, str]
    description: Optional[Dict[str, str]] = None
    imageRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    active: Optional[bool] = True
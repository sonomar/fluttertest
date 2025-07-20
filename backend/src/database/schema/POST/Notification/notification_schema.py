import datetime
from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List

# --- Notification Schemas ---
class NotificationCreate(BaseModel):
    header: Dict[str, str]
    content: Dict[str, str]
    link: Optional[Dict[str, Any]] = None
    pushNotification: Optional[bool] = False
    private: Optional[bool] = False
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    active: Optional[bool] = True
    publishDt: Optional[datetime.datetime] = None # New field
    notifyData: Optional[Dict[str, Any]] = None # New field
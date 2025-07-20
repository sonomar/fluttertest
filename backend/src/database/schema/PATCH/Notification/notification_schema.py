from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

# --- Notification Schemas ---
class NotificationUpdate(BaseModel):
    header: Optional[Dict[str, str]] = None
    content: Optional[Dict[str, str]] = None
    link: Optional[Dict[str, Any]] = None
    pushNotification: Optional[bool] = None
    private: Optional[bool] = None
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    publishDt: Optional[datetime.datetime] = None # New field
    notifyData: Optional[Dict[str, Any]] = None # New field
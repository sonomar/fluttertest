from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List

# --- Notification Schemas ---
class NotificationUpdate(BaseModel):
    header: Optional[str] = None
    content: Optional[str] = None
    link: Optional[Dict[str, Any]] = None
    pushNotification: Optional[bool] = None
    private: Optional[bool] = None
    imgRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
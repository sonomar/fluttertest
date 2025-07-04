from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

# --- Notification Schemas ---
class NotificationResponse(BaseModel):
    notificationId: int
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
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
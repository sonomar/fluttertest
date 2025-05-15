from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# --- Notification Schemas ---
class NotificationResponse(BaseModel):
    notificationId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime
    header: str
    content: str
    link: Optional[Dict[str, Any]] = None
    pushNotification: Optional[bool] = False
    private: Optional[bool] = False
    imgRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[str] = None # Corrected type based on model
    active: Optional[bool] = True

    class Config:
        from_attributes = True
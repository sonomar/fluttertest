from pydantic import BaseModel
from typing import Optional, Dict, Any

# --- Notification Schemas ---
class NotificationUpdate(BaseModel):
    header: Optional[str] = None
    content: Optional[str] = None
    link: Optional[Dict[str, Any]] = None
    pushNotification: Optional[bool] = None
    private: Optional[bool] = None
    imgRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[str] = None
    active: Optional[bool] = None
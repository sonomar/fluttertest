from pydantic import BaseModel
from typing import Optional, Dict, Any

class NotificationUserUpdate(BaseModel):
    notificationId: Optional[int] = None
    userId: Optional[int] = None
    markRead: Optional[bool] = None
    archived: Optional[bool] = None
    deleted: Optional[bool] = None
    pushNotification: Optional[bool] = None
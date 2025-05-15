from pydantic import BaseModel
from typing import Optional

class NotificationUserCreate(BaseModel):
    notificationId: int
    userId: int
    markRead: Optional[bool] = False
    archived: Optional[bool] = False
    deleted: Optional[bool] = False
    pushNotification: Optional[bool] = False
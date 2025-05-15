from pydantic import BaseModel
from typing import Optional
import datetime

class NotificationUserResponse(BaseModel):
    notificationUserId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime
    notificationId: int
    userId: int
    markRead: Optional[bool] = False
    archived: Optional[bool] = False
    deleted: Optional[bool] = False
    pushNotification: Optional[bool] = False

    class Config:
        from_attributes = True
from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Dict, Any

from database.db import get_db
from database.models import NotificationUser
from database.schema.PATCH.NotificationUser.notificationUser_schema import NotificationUserUpdate
from database.schema.GET.NotificationUser.notificationUser_schema import NotificationUserResponse
from api.exceptions import NotFoundException, ConflictException, BadRequestException

def updateNotificationUserByNotificationUserId(
    notificationUserId: int = Path(..., description="ID of the notification user record to update"),
    notification_user_update_data: NotificationUserUpdate = Body(..., description="Data to update notification user"),
    db: Session = Depends(get_db)
) -> NotificationUserResponse:
    db_notification_user = db.query(NotificationUser).filter(NotificationUser.notificationUserId == notificationUserId).first()

    if db_notification_user is None:
        raise NotFoundException(detail=f"Notification user record with ID {notificationUserId} not found")

    update_data = notification_user_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_notification_user, field):
            setattr(db_notification_user, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on NotificationUser model.")

    try:
        db.commit()
        db.refresh(db_notification_user)
        return db_notification_user
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating notification user {notificationUserId}: {error_message}")
        if 'Duplicate entry' in error_message and "'notificationId'" in error_message and "'userId'":
            raise ConflictException(detail=f"This notification is already associated with this user.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating notification user {notificationUserId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
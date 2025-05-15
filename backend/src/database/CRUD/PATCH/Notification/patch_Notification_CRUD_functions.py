from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Notification
from database.schema.PATCH.Notification.notification_schema import NotificationUpdate
from database.schema.GET.Notification.notification_schema import NotificationResponse
from api.exceptions import NotFoundException, BadRequestException

def updateNotificationByNotificationId(
    notificationId: int = Path(..., description="ID of the notification to update"),
    notification_update_data: NotificationUpdate = Body(..., description="Data to update notification"),
    db: Session = Depends(get_db)
) -> NotificationResponse:
    db_notification = db.query(Notification).filter(Notification.notificationId == notificationId).first()

    if db_notification is None:
        raise NotFoundException(detail=f"Notification with ID {notificationId} not found")

    update_data = notification_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_notification, field):
            setattr(db_notification, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on Notification model.")

    try:
        db.commit()
        db.refresh(db_notification)
        return db_notification
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating notification {notificationId}: {error_message}")
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating notification {notificationId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
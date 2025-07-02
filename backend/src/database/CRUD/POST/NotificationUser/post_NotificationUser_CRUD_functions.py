from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import NotificationUser
from database.schema.POST.NotificationUser.notificationUser_schema import NotificationUserCreate
# Assuming a GET/NotificationUser/notificationUser_schema.py exists or similar naming
from database.schema.GET.NotificationUser.notificationUser_schema import NotificationUserResponse # Updated import for response schema
from api.exceptions import ConflictException, BadRequestException

def createNotificationUser(
    notification_user: NotificationUserCreate,
    db: Session = Depends(get_db)
) -> NotificationUserResponse: # Updated return type
    """
    Adds a new notification user entry to the database using SQLAlchemy.
    """
    db_notification_user = NotificationUser(
        notificationId=notification_user.notificationId,
        userId=notification_user.userId,
        markRead=notification_user.markRead,
        archived=notification_user.archived,
        deleted=notification_user.deleted,
        pushNotification=notification_user.pushNotification
    )

    try:
        db.add(db_notification_user)
        db.commit()
        db.refresh(db_notification_user)
        return NotificationUserResponse.model_validate(db_notification_user) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating notification user: {error_message}")
        if 'Duplicate entry' in error_message and 'unique_notification_user' in error_message:
            raise ConflictException(detail=f"NotificationUser entry for notificationId '{notification_user.notificationId}' and userId '{notification_user.userId}' already exists.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating notification user: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Notification
from database.schema.POST.Notification.notification_schema import NotificationCreate
# Assuming a GET/Notification/notification_schema.py exists or similar naming
from database.schema.GET.Notification.notification_schema import NotificationResponse # Updated import for response schema
from api.exceptions import ConflictException, BadRequestException

def createNotification(
    notification: NotificationCreate,
    db: Session = Depends(get_db)
) -> NotificationResponse: # Updated return type
    """
    Adds a new notification to the database using SQLAlchemy.
    """
    db_notification = Notification(
        header=notification.header,
        content=notification.content,
        link=notification.link,
        pushNotification=notification.pushNotification,
        private=notification.private,
        imgRef=notification.imgRef,
        vidRef=notification.vidRef,
        qrRef=notification.qrRef,
        embedRef=notification.embedRef,
        active=notification.active,
        publishDt=notification.publishDt, # New field
        notifyData=notification.notifyData # New field
    )

    try:
        db.add(db_notification)
        db.commit()
        db.refresh(db_notification)
        return NotificationResponse.model_validate(db_notification) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating notification: {error_message}")
        # Add specific checks if there are unique constraints on notification fields
        raise BadRequestException(detail=f"Database integrity error: {e}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating notification: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
# database/CRUD/GET/Notification/get_Notification_CRUD_functions.py
from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List
import datetime

from database.db import get_db
from database.models import Notification
from database.schema.GET.Notification.notification_schema import NotificationResponse
from api.exceptions import NotFoundException

def getNotificationByNotificationId(
    notificationId: int = Query(..., description="ID of the notification to retrieve"),
    db: Session = Depends(get_db)
) -> NotificationResponse:
    db_notification = db.query(Notification).filter(Notification.notificationId == notificationId).first()
    if db_notification is None:
        raise NotFoundException(detail=f"Notification with ID {notificationId} not found")
    return db_notification

def getNotificationsByDate(
    createdDtAfter: datetime.datetime = Query(..., description="Timestamp to retrieve notifications created after"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[NotificationResponse]:
    notifications = db.query(Notification)\
                      .filter(Notification.createdDt >= createdDtAfter)\
                      .offset(skip)\
                      .limit(limit)\
                      .all()
    return notifications

def getNotificationsByHeader(
    header: str = Query(..., description="Header of the notification to retrieve"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[NotificationResponse]:
    notifications = db.query(Notification).filter(Notification.header.ilike(f"%{header}%")).offset(skip).limit(limit).all()
    return notifications
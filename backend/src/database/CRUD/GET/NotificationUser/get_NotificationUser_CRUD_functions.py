# database/CRUD/GET/NotificationUser/get_NotificationUser_CRUD_functions.py
from fastapi import Depends, Query, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import datetime

from database.db import get_db
from database.models import NotificationUser
from database.schema.GET.NotificationUser.notificationUser_schema import NotificationUserResponse

def getNotificationUsersByUserId(
    userId: int = Query(..., description="ID of the user to retrieve notification user records for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[NotificationUserResponse]:
    notification_users = db.query(NotificationUser).filter(NotificationUser.userId == userId).offset(skip).limit(limit).all()
    return notification_users

def getNotificationUsersByNotificationId(
    notificationId: int = Query(..., description="ID of the notification to retrieve notification user records for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[NotificationUserResponse]:
    notification_users = db.query(NotificationUser).filter(NotificationUser.notificationId == notificationId).offset(skip).limit(limit).all()
    return notification_users

def getNotificationUsersByUserIdAndDate(
    userId: int = Query(..., description="ID of the user"),
    createdDtAfter: datetime.datetime = Query(..., description="Timestamp to retrieve notification user records created after"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[NotificationUserResponse]:
    notification_users = db.query(NotificationUser)\
                          .filter(NotificationUser.userId == userId, NotificationUser.createdDt >= createdDtAfter)\
                          .offset(skip)\
                          .limit(limit)\
                          .all()
    return notification_users
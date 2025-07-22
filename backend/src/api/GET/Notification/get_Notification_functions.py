# database/CRUD/GET/Notification/get_Notification_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.Notification.get_Notification_CRUD_functions as crudFunctions

def getAllNotifications(event):
    """
    Retrieves all notifications.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if data is not None:
        if "skip" in data:
            try:
                skip_param = data.get("skip")
                if skip_param is not None: 
                    skip = int(skip_param)
            except (ValueError, TypeError):
                print(f"Warning: Invalid 'skip' parameter value: {data.get('skip')}. Using default {skip}.")
        if "limit" in data:
            try:
                limit_param = data.get("limit")
                if limit_param is not None:
                    limit = int(limit_param)
            except (ValueError, TypeError):
                print(f"Warning: Invalid 'limit' parameter value: {data.get('limit')}. Using default {limit}.")
    else:
        print("Debug: No query parameters ('skip', 'limit') found for getAllNotifications. Using defaults.")

    db_session = event.get('db_session')
    if db_session is None:
        print("Error: db_session not found in event for getAllNotifications.")

    return crudFunctions.getAllNotifications(skip=skip, limit=limit, db=db_session)

def getNotificationByNotificationId(event):
    """
    Retrieves a notification by its notificationId.
    Requires 'notificationId' in the request data.
    """
    data = extractData(event)
    if not data or "notificationId" not in data:
        return {'statusCode': 400, 'body': 'notificationId is required'}

    notification_id = data["notificationId"]
    return crudFunctions.getNotificationByNotificationId(notificationId=notification_id, db=event['db_session'])

def getNotificationsByDate(event):
    """
    Retrieves notifications by creation date.
    Requires 'createdDtAfter' timestamp in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "createdDtAfter" not in data:
        return {'statusCode': 400, 'body': 'createdDtAfter timestamp is required'}

    created_dt_after = data["createdDtAfter"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getNotificationsByDate(createdDtAfter=created_dt_after, skip=skip, limit=limit, db=event['db_session'])

def getNotificationsByHeader(event):
    """
    Retrieves notifications by their header.
    Requires 'header' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "header" not in data:
        return {'statusCode': 400, 'body': 'header is required'}

    header = data["header"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getNotificationsByHeader(header=header, skip=skip, limit=limit, db=event['db_session'])
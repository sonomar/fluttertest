from tools.prod.prodTools import extractData
import database.CRUD.PATCH.Notification.patch_Notification_CRUD_functions as crudFunctions
from database.schema.PATCH.Notification.notification_schema import NotificationUpdate

def NotificationDataCheck(notification: NotificationUpdate, data: any):
    if "header" in data:
        notification.header = data["header"]
    if "content" in data:
        notification.content = data["content"]
    if "link" in data:
        notification.link = data["link"]
    if "pushNotification" in data:
        notification.pushNotification = data["pushNotification"]
    if "private" in data:
        notification.private = data["private"]
    if "imgRef" in data:
        notification.imgRef = data["imgRef"]
    if "vidRef" in data:
        notification.vidRef = data["vidRef"]
    if "qrRef" in data:
        notification.qrRef = data["qrRef"]
    if "embedRef" in data:
        notification.embedRef = data["embedRef"]
    if "active" in data:
        notification.active = data["active"]
    if "publishDt" in data:
        notification.publishDt = data["publishDt"]
    if "notifyData" in data:
        notification.notifyData = data["notifyData"]
    return notification

def updateNotificationByNotificationId(event):
    data = extractData(event)
    if not data or "notificationId" not in data:
        return {'statusCode': 400, 'body': 'notificationId is required'}

    notification_id = data["notificationId"]
    notification = NotificationUpdate()
    notification = NotificationDataCheck(notification, data)
    return crudFunctions.updateNotificationByNotificationId(notificationId=notification_id, notification_update_data=notification, db=event['db_session'])
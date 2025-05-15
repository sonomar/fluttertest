from tools.prod.prodTools import extractData
import database.CRUD.PATCH.NotificationUser.patch_NotificationUser_CRUD_functions as crudFunctions
from database.schema.PATCH.NotificationUser.notificationUser_schema import NotificationUserUpdate

def NotificationUserDataCheck(notificationUser: NotificationUserUpdate, data: any):
    if "notificationId" in data:
        notificationUser.notificationId = data["notificationId"]
    if "userId" in data:
        notificationUser.userId = data["userId"]
    if "markRead" in data:
        notificationUser.markRead = data["markRead"]
    if "archived" in data:
        notificationUser.archived = data["archived"]
    if "deleted" in data:
        notificationUser.deleted = data["deleted"]
    if "pushNotification" in data:
        notificationUser.pushNotification = data["pushNotification"]
    return notificationUser

def updateNotificationUserByNotificationUserId(event):
    data = extractData(event)
    if not data or "notificationUserId" not in data:
        return {'statusCode': 400, 'body': 'notificationUserId is required'}

    notification_user_id = data["notificationUserId"]
    notification_user = NotificationUserUpdate()
    notification_user = NotificationUserDataCheck(notification_user, data)
    return crudFunctions.updateNotificationUserByNotificationUserId(notificationUserId=notification_user_id, notification_user_update_data=notification_user, db=event['db_session'])
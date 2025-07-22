import api.GET.Notification.get_Notification_functions as notification
from api.GET.api_paths_get import API_PATHS_GET

def call_Notification_function(raw_path, event):

    returnString = 'Invalid Function Call'
    Notification_Path = API_PATHS_GET['Notification']

    ## Notification
    if raw_path == Notification_Path['getNotificationByNotificationId']['path']:
        returnString = notification.getNotificationByNotificationId(event)
    
    elif raw_path == Notification_Path['getAllNotifications']['path']:
        returnString = notification.getAllNotifications(event)

    elif raw_path == Notification_Path['getNotificationsByDate']['path']:
        returnString = notification.getNotificationsByDate(event)

    elif raw_path == Notification_Path['getNotificationsByHeader']['path']:
        returnString = notification.getUsergetNotificationsByHeaderByUsername(event)
    
    return returnString
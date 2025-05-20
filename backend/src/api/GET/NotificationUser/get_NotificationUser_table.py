import api.GET.NotificationUser.get_NotificationUser_functions as notificationUser
from api.GET.api_paths_get import API_PATHS_GET

def call_NotificationUser_function(raw_path, event):

    returnString = 'Invalid Function Call'
    NotificationUser_Path = API_PATHS_GET['NotificationUser']

    ## NotificationUser
    if raw_path == NotificationUser_Path['getNotificationUsersByUserId']['path']:
        returnString = notificationUser.getNotificationUsersByUserId(event)

    elif raw_path == NotificationUser_Path['getNotificationUsersByNotificationId']['path']:
        returnString = notificationUser.getNotificationUsersByNotificationId(event)

    elif raw_path == NotificationUser_Path['getNotificationUsersByUserIdAndDate']['path']:
        returnString = notificationUser.getNotificationUsersByUserIdAndDate(event)
    
    return returnString
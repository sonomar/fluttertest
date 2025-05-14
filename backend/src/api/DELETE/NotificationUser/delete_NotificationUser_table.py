import api.DELETE.NotificationUser.delete_NotificationUser_functions as notificationUserFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_NotificationUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    NotificationUser_Path = API_PATHS_DELETE['NotificationUser']

    ## NotificationUser
    if raw_path == NotificationUser_Path['deleteNotificationUserByNotificationUserId']['path']:
        returnString = notificationUserFunctions.deleteNotificationUserByNotificationUserId(event)

    return returnString
import api.POST.Notification.post_Notification_functions as notification
from api.POST.api_paths_post import API_PATHS_POST

def call_Notification_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Notification_Path = API_PATHS_POST['Notification']

    ## Notification
    if raw_path == Notification_Path['createNotification']['path']:
        returnString = notification.create_notification(event)

    return returnString
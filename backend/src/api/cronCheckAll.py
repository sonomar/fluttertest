from api.GET.http_router_get import http_router_get
from api.CRON.notification_scheduler import notificationScheduler

NOTIFICATION_CRON_NAME = 'notification-scheduler'
HTTP_METHOD_POST = 'POST' 
HTTP_METHOD_PATCH = 'PATCH'
HTTP_METHOD_DELETE = 'DELETE'


def cron_router_all(event):
    cron_method = event.get('scheduler-name')
    returnString = 'Invalid Call Type'
    
    if cron_method == NOTIFICATION_CRON_NAME:
        returnString = notificationScheduler(event)

    return returnString
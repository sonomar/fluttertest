from api.GET.http_router_get import http_router_get
from api.PATCH.http_router_patch import http_router_patch
from api.POST.http_router_post import http_router_post
from api.DELETE.http_router_delete import http_router_delete

HTTP_METHOD_GET = 'GET'
HTTP_METHOD_POST = 'POST' 
HTTP_METHOD_PATCH = 'PATCH'
HTTP_METHOD_DELETE = 'DELETE'


def http_router_all(event):
    http_method = event.get('requestContext')["http"]["method"]
    returnString = 'Invalid Call Type'
    
    if http_method == HTTP_METHOD_GET:
        returnString = http_router_get(event)

    elif http_method == HTTP_METHOD_PATCH:
        returnString = http_router_patch(event)
    
    if http_method == HTTP_METHOD_POST:
        returnString = http_router_post(event)

    elif http_method == HTTP_METHOD_DELETE:
        returnString = http_router_delete(event)

    return returnString


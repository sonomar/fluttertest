import api.DELETE.api_path_delete as api_path_delete
from tools.prod.prodTools import split_string

def http_router_delete(event):
    
    raw_path = split_string(f"{event['rawPath']}")
    returnString = 'Invalid Function Call'

    return returnString
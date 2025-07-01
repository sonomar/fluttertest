import api.POST.Collection.post_Collection_functions as collection
from api.POST.api_paths_post import API_PATHS_POST

def call_Collection_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Collection_Path = API_PATHS_POST['Collection']

    ## Collection
    if raw_path == Collection_Path['createCollection']['path']:
        returnString = collection.createCollection(event)

    return returnString
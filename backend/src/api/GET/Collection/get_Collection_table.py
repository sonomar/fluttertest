import api.GET.Collection.get_Collection_functions as collection
from api.GET.api_paths_get import API_PATHS_GET

def call_Collection_function(raw_path, event):

    returnString = 'Invalid Function Call'
    Collection_Path = API_PATHS_GET['Collection']

    ## Collection
    if raw_path == Collection_Path['getCollectionById']['path']:
        returnString = collection.getCollectionByCollectionId(event)

    elif raw_path == Collection_Path['getCollectionByName']['path']:
        returnString = collection.getCollectionByName(event)

    
    return returnString
import api.DELETE.Collection.delete_Collection_functions as collectionFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_Collection_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Collection_Path = API_PATHS_DELETE['Collection']

    ## Collection
    if raw_path == Collection_Path['deleteCollectionByCollectionId']['path']:
        returnString = collectionFunctions.deleteCollectionByCollectionId(event)

    return returnString
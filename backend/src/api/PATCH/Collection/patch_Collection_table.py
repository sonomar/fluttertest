import api.PATCH.Collection.patch_Collection_functions as collection
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_Collection_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Collection_Path = API_PATHS_PATCH['Collection']

    ## Collection
    if raw_path == Collection_Path['updateCollectionByCollectionId']['path']:
        returnString = collection.updateCollectionByCollectionId(event)

    return returnString
import api.DELETE.CollectibleSponsor.delete_CollectibleSponsor_functions as collectibleSponsorFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_CollectibleSponsor_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    CollectibleSponsor_Path = API_PATHS_DELETE['CollectibleSponsor']

    ## CollectibleSponsor
    if raw_path == CollectibleSponsor_Path['deleteCollectibleSponsorByCollectibleSponsorId']['path']:
        returnString = collectibleSponsorFunctions.deleteCollectibleSponsorByCollectibleSponsorId(event)

    return returnString
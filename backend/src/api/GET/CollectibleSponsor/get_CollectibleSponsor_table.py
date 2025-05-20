import api.GET.CollectibleSponsor.get_CollectibleSponsor_functions as collectibleSponsor
from api.GET.api_paths_get import API_PATHS_GET

def call_CollectibleSponsor_function(raw_path, event):

    returnString = 'Invalid Function Call'
    CollectibleSponsor_Path = API_PATHS_GET['CollectibleSponsor']

    ## CollectibleSponsor
    if raw_path == CollectibleSponsor_Path['getCollectibleSponsorByCollectibleSponsorId']['path']:
        returnString = collectibleSponsor.getCollectibleSponsorByCollectibleSponsorId(event)

    elif raw_path == CollectibleSponsor_Path['getCollectibleSponsorByCollectibleId']['path']:
        returnString = collectibleSponsor.getCollectibleSponsorByCollectibleId(event)

    elif raw_path == CollectibleSponsor_Path['getCollectibleSponsorBySponsorId']['path']:
        returnString = collectibleSponsor.getCollectibleSponsorBySponsorId(event)
    
    return returnString
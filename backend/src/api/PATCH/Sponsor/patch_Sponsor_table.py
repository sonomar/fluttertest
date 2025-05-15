import api.PATCH.Sponsor.patch_Sponsor_functions as sponsor
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_Sponsor_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Sponsor_Path = API_PATHS_PATCH['Sponsor']

    ## Sponsor
    if raw_path == Sponsor_Path['updateSponsorBySponsorId']['path']:
        returnString = sponsor.updateSponsorBySponsorId(event)

    return returnString
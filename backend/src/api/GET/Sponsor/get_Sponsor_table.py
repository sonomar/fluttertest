import api.GET.Sponsor.get_Sponsor_functions as sponsor
from api.GET.api_paths_get import API_PATHS_GET

def call_Sponsor_function(raw_path, event):

    returnString = 'Invalid Function Call'
    Sponsor_Path = API_PATHS_GET['User']

    ## Sponsor
    if raw_path == Sponsor_Path['getSponsorBySponsorId']['path']:
        returnString = sponsor.getSponsorBySponsorId(event)

    elif raw_path == Sponsor_Path['getSponsorByName']['path']:
        returnString = sponsor.getSponsorByName(event)

    elif raw_path == Sponsor_Path['getSponsorByOrganization']['path']:
        returnString = sponsor.getSponsorByOrganization(event)
    
    return returnString
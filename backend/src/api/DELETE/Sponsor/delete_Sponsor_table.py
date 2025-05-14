import api.DELETE.Sponsor.delete_Sponsor_functions as sponsorFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_Sponsor_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Sponsor_Path = API_PATHS_DELETE['Sponsor']

    ## Sponsor
    if raw_path == Sponsor_Path['deleteSponsorBySponsorId']['path']:
        returnString = sponsorFunctions.deleteSponsorBySponsorId(event)

    return returnString
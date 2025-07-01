import api.POST.Sponsor.post_Sponsor_functions as sponsor
from api.POST.api_paths_post import API_PATHS_POST

def call_Sponsor_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Sponsor_Path = API_PATHS_POST['Sponsor']

    ## Sponsor
    if raw_path == Sponsor_Path['createSponsor']['path']:
        returnString = sponsor.createSponsor(event)

    return returnString
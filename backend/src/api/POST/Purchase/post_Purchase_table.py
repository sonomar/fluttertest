# Ankit TBD
import api.POST.Purchase.post_Purchase_functions as purchase
from api.POST.api_paths_post import API_PATHS_POST

def call_Purchase_function(raw_path, event):

    returnString = 'Invalid Function Call'
    Purchase_Path = API_PATHS_POST['Purchase']

    if raw_path == Purchase_Path['createPurchase']['path']:
        returnString = purchase.createPurchase(event)

    return returnString
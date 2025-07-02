import api.POST.Category.post_Category_functions as category
from api.POST.api_paths_post import API_PATHS_POST

def call_Category_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Category_Path = API_PATHS_POST['Category']

    ## Category
    if raw_path == Category_Path['createCategory']['path']:
        returnString = category.createCategory(event)

    return returnString
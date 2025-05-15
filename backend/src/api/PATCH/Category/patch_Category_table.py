import api.PATCH.Category.patch_Category_functions as category
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_Category_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Category_Path = API_PATHS_PATCH['Category']

    ## Category
    if raw_path == Category_Path['updateCategoryByCategoryId']['path']:
        returnString = category.updateCategoryByCategoryId(event)

    return returnString
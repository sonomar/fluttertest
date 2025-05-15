import api.PATCH.NewsPost.patch_NewsPost_functions as newsPost
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_NewsPost_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    NewsPost_Path = API_PATHS_PATCH['NewsPost']

    ## NewsPost
    if raw_path == NewsPost_Path['updateNewsPostByNewsPostId']['path']:
        returnString = newsPost.updateNewsPostByNewsPostId(event)

    return returnString
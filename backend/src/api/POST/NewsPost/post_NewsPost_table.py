import api.POST.NewsPost.post_NewsPost_functions as newsPost
from api.POST.api_paths_post import API_PATHS_POST

def call_NewsPost_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    NewsPost_Path = API_PATHS_POST['NewsPost']

    ## NewsPost
    if raw_path == NewsPost_Path['createNewsPost']['path']:
        returnString = newsPost.create_news_post(event)

    return returnString
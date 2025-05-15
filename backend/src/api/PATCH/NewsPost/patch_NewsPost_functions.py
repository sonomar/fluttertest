from tools.prod.prodTools import extractData
import database.CRUD.PATCH.NewsPost.patch_NewsPost_CRUD_functions as crudFunctions
from database.schema.PATCH.NewsPost.newsPost_schema import NewsPostUpdate
import datetime

def NewsPostDataCheck(newsPost: NewsPostUpdate, data: any):
    if "header" in data:
        newsPost.header = data["header"]
    if "body" in data:
        newsPost.body = data["body"]
    if "shortBody" in data:
        newsPost.shortBody = data["shortBody"]
    if "postDate" in data:
        if isinstance(data["postDate"], str):
             newsPost.postDate = datetime.datetime.fromisoformat(data["postDate"])
        else:
             newsPost.postDate = data["postDate"]
    if "type" in data:
        newsPost.type = data["type"]
    if "imgRef" in data:
        newsPost.imgRef = data["imgRef"]
    if "vidRef" in data:
        newsPost.vidRef = data["vidRef"]
    if "qrRef" in data:
        newsPost.qrRef = data["qrRef"]
    if "embedRef" in data:
        newsPost.embedRef = data["embedRef"]
    if "active" in data:
        newsPost.active = data["active"]
    return newsPost

def updateNewsPostByNewsPostId(event):
    data = extractData(event)
    if not data or "newsPostId" not in data:
        return {'statusCode': 400, 'body': 'newsPostId is required'}

    news_post_id = data["newsPostId"]
    news_post = NewsPostUpdate()
    news_post = NewsPostDataCheck(news_post, data)
    return crudFunctions.updateNewsPostByNewsPostId(newsPostId=news_post_id, news_post_update_data=news_post, db=event['db_session'])
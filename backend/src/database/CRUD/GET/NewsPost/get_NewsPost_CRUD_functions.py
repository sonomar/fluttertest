# database/CRUD/GET/NewsPost/get_NewsPost_CRUD_functions.py
from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List
import datetime

from database.db import get_db
from database.models import NewsPost
from database.schema.GET.NewsPost.newsPost_schema import NewsPostResponse
from api.exceptions import NotFoundException

def getNewsPostByNewsPostId(
    newsPostId: int = Query(..., description="ID of the news post to retrieve"),
    db: Session = Depends(get_db)
) -> NewsPostResponse:
    db_news_post = db.query(NewsPost).filter(NewsPost.newsPostId == newsPostId).first()
    if db_news_post is None:
        raise NotFoundException(detail=f"News post with ID {newsPostId} not found")
    return db_news_post

def getNewsPostsByDate(
    postDateAfter: datetime.datetime = Query(..., description="Timestamp to retrieve news posts published after"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[NewsPostResponse]:
    news_posts = db.query(NewsPost)\
                   .filter(NewsPost.postDate >= postDateAfter)\
                   .offset(skip)\
                   .limit(limit)\
                   .all()
    return news_posts

def getNewsPostsByHeader(
    header: str = Query(..., description="Header of the news post to retrieve"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[NewsPostResponse]:
    news_posts = db.query(NewsPost).filter(NewsPost.header.ilike(f"%{header}%")).offset(skip).limit(limit).all()
    return news_posts
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import NewsPost
from database.schema.POST.NewsPost.newsPost_schema import NewsPostCreate
# Assuming a GET/NewsPost/newsPost_schema.py exists or similar naming
from database.schema.GET.NewsPost.newsPost_schema import NewsPostResponse # Updated import for response schema
from api.exceptions import BadRequestException

def createNewsPost(
    news_post: NewsPostCreate,
    db: Session = Depends(get_db)
) -> NewsPostResponse: # Updated return type
    """
    Adds a new news post to the database using SQLAlchemy.
    """
    db_news_post = NewsPost(
        header=news_post.header,
        body=news_post.body,
        shortBody=news_post.shortBody,
        postDate=news_post.postDate,
        type=news_post.type,
        imgRef=news_post.imgRef,
        vidRef=news_post.vidRef,
        qrRef=news_post.qrRef,
        embedRef=news_post.embedRef,
        active=news_post.active
    )

    try:
        db.add(db_news_post)
        db.commit()
        db.refresh(db_news_post)
        return NewsPostResponse.model_validate(db_news_post) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating news post: {error_message}")
        # Add specific checks if there are unique constraints on news post fields
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating news post: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Dict, Any

from database.db import get_db
from database.models import NewsPost
from database.schema.PATCH.NewsPost.newsPost_schema import NewsPostUpdate
from database.schema.GET.NewsPost.newsPost_schema import NewsPostResponse
from api.exceptions import NotFoundException, BadRequestException

def updateNewsPostByNewsPostId(
    newsPostId: int = Path(..., description="ID of the news post to update"),
    news_post_update_data: NewsPostUpdate = Body(..., description="Data to update news post"),
    db: Session = Depends(get_db)
) -> NewsPostResponse:
    db_news_post = db.query(NewsPost).filter(NewsPost.newsPostId == newsPostId).first()

    if db_news_post is None:
        raise NotFoundException(detail=f"News post with ID {newsPostId} not found")

    update_data = news_post_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_news_post, field):
            setattr(db_news_post, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on NewsPost model.")

    try:
        db.commit()
        db.refresh(db_news_post)
        return db_news_post
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating news post {newsPostId}: {error_message}")
        # Add specific integrity error handling if needed (e.g., for unique headers)
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating news post {newsPostId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
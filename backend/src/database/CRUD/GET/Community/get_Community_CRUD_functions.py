# database/CRUD/GET/Community/get_Community_CRUD_functions.py
from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import Community
from database.schema.GET.Community.community_schema import CommunityResponse
from api.exceptions import NotFoundException

def getCommunityById(
    communityId: int = Query(..., description="ID of the community to retrieve"),
    db: Session = Depends(get_db)
) -> CommunityResponse:
    db_community = db.query(Community).filter(Community.communityId == communityId).first()
    if db_community is None:
        raise NotFoundException(detail=f"Community with ID {communityId} not found")
    return db_community

def getCommunityByTitle(
    title: str = Query(..., description="Title of the community to retrieve"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CommunityResponse]:
    communities = db.query(Community).filter(Community.title.ilike(f"%{title}%")).offset(skip).limit(limit).all()
    return communities
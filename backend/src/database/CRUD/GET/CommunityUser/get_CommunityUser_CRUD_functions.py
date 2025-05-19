# database/CRUD/GET/CommunityUser/get_CommunityUser_CRUD_functions.py
from fastapi import Depends, Query, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from database.db import get_db
from database.models import CommunityUser
from database.schema.GET.CommunityUser.communityUser_schema import CommunityUserResponse

def getCommunityUsersByUserId(
    userId: int = Query(..., description="ID of the user to retrieve community memberships for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CommunityUserResponse]:
    community_users = db.query(CommunityUser).filter(CommunityUser.memberId == userId).offset(skip).limit(limit).all()
    return community_users

def getCommunityUsersByCommunityId(
    communityId: int = Query(..., description="ID of the community to retrieve members for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CommunityUserResponse]:
    community_users = db.query(CommunityUser).filter(CommunityUser.communityId == communityId).offset(skip).limit(limit).all()
    return community_users
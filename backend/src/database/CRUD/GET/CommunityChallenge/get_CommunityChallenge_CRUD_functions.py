# database/CRUD/GET/CommunityChallenge/get_CommunityChallenge_CRUD_functions.py
from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import CommunityChallenge
from database.schema.GET.CommunityChallenge.communityChallenge_schema import CommunityChallengeResponse
from api.exceptions import NotFoundException

def getCommunityChallengeByCommunityChallengeId(
    communityChallengeId: int = Query(..., description="ID of the community challenge to retrieve"),
    db: Session = Depends(get_db)
) -> CommunityChallengeResponse:
    db_community_challenge = db.query(CommunityChallenge).filter(CommunityChallenge.communityChallengeId == communityChallengeId).first()
    if db_community_challenge is None:
        raise NotFoundException(detail=f"Community challenge with ID {communityChallengeId} not found")
    return db_community_challenge

def getCommunityChallengeByTitle(
    title: str = Query(..., description="Title of the community challenge to retrieve"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CommunityChallengeResponse]:
    community_challenges = db.query(CommunityChallenge).filter(CommunityChallenge.title.ilike(f"%{title}%")).offset(skip).limit(limit).all()
    return community_challenges
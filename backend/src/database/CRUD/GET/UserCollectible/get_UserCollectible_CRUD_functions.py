# database/CRUD/GET/UserCollectible/get_UserCollectible_CRUD_functions.py
from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List
import datetime

from database.db import get_db
from database.models import UserCollectible
from database.schema.GET.UserCollectible.userCollectible_schema import UserCollectibleResponse
from api.exceptions import NotFoundException

def getUserCollectibleByCollectibleIdAndMint(
    collectibleId: int = Query(..., description="ID of the collectible"),
    mint: int = Query(..., description="Mint number of the collectible"),
    db: Session = Depends(get_db)
) -> UserCollectibleResponse:
    db_user_collectible = db.query(UserCollectible).filter(
        UserCollectible.collectibleId == collectibleId,
        UserCollectible.mint == mint
    ).first()
    if db_user_collectible is None:
        raise NotFoundException(detail=f"UserCollectible with collectibleId {collectibleId} and mint {mint} not found")
    return db_user_collectible

def getUserCollectiblesByOwnerId(
    ownerId: int = Query(..., description="ID of the owner to retrieve collectibles for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[UserCollectibleResponse]:
    user_collectibles = db.query(UserCollectible).filter(UserCollectible.ownerId == ownerId).offset(skip).limit(limit).all()
    return user_collectibles

def getUserCollectiblesByLastOwned(
    lastTransferredDtAfter: datetime.datetime = Query(..., description="Timestamp to retrieve user collectibles transferred after"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[UserCollectibleResponse]:
    user_collectibles = db.query(UserCollectible)\
                          .filter(UserCollectible.lastTransferredDt >= lastTransferredDtAfter)\
                          .offset(skip)\
                          .limit(limit)\
                          .all()
    return user_collectibles

def getUserCollectiblesByCollectibleId(
    collectibleId: int = Query(..., description="ID of the collectible to retrieve user collectibles for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[UserCollectibleResponse]:
    user_collectibles = db.query(UserCollectible).filter(UserCollectible.collectibleId == collectibleId).offset(skip).limit(limit).all()
    return user_collectibles
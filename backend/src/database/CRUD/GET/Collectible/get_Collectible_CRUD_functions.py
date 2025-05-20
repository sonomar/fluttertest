# database/CRUD/GET/Collectible/get_Collectible_CRUD_functions.py
from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import Collectible, CollectibleSponsor
from database.schema.GET.Collectible.collectible_schema import CollectibleResponse
from api.exceptions import NotFoundException

def getCollectibleByCollectibleId(
    collectibleId: int = Query(..., description="ID of the collectible to retrieve"),
    db: Session = Depends(get_db)
) -> CollectibleResponse:
    db_collectible = db.query(Collectible).filter(Collectible.collectibleId == collectibleId).first()
    if db_collectible is None:
        raise NotFoundException(detail=f"Collectible with ID {collectibleId} not found")
    return db_collectible

def getCollectibleByName(
    name: str = Query(..., description="Name of the collectible to retrieve"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CollectibleResponse]:
    collectibles = db.query(Collectible).filter(Collectible.name.ilike(f"%{name}%")).offset(skip).limit(limit).all()
    return collectibles

def getCollectiblesByLabel(
    label: str = Query(..., description="Label of the collectible to retrieve"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CollectibleResponse]:
    collectibles = db.query(Collectible).filter(Collectible.label.ilike(f"%{label}%")).offset(skip).limit(limit).all()
    return collectibles

def getCollectiblesBySponsor(
    sponsorId: int = Query(..., description="ID of the sponsor to retrieve collectibles by"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CollectibleResponse]:
    collectibles = db.query(Collectible).join(CollectibleSponsor).filter(CollectibleSponsor.sponsorId == sponsorId).offset(skip).limit(limit).all()
    return collectibles

def getCollectiblesByCollection(
    collectionId: int = Query(..., description="ID of the collection to retrieve collectibles from"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CollectibleResponse]:
    collectibles = db.query(Collectible).filter(Collectible.collectionId == collectionId).offset(skip).limit(limit).all()
    return collectibles

def getCollectiblesByCommunity(
    communityId: int = Query(..., description="ID of the community to retrieve collectibles from"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CollectibleResponse]:
    collectibles = db.query(Collectible).filter(Collectible.communityId == communityId).offset(skip).limit(limit).all()
    return collectibles

def getAllCollectibles(
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CollectibleResponse]:
    """
    Retrieves all collectibles with pagination.
    """
    collectibles = db.query(Collectible).offset(skip).limit(limit).all()
    return collectibles

def getCollectiblesByProjectId(
    projectId: int = Query(..., description="ID of the project to retrieve collectibles from"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CollectibleResponse]:
    """
    Retrieves collectibles associated with a specific project ID, with pagination.
    """
    collectibles = db.query(Collectible).filter(Collectible.projectId == projectId).offset(skip).limit(limit).all()
    return collectibles

def getCollectiblesByCategoryId(
    categoryId: int = Query(..., description="ID of the category to retrieve collectibles from"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CollectibleResponse]:
    """
    Retrieves collectibles associated with a specific category ID, with pagination.
    """
    collectibles = db.query(Collectible).filter(Collectible.categoryId == categoryId).offset(skip).limit(limit).all()
    return collectibles
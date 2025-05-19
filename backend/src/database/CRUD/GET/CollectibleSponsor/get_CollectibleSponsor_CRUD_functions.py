# database/CRUD/GET/CollectibleSponsor/get_CollectibleSponsor_CRUD_functions.py
from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import CollectibleSponsor
from database.schema.GET.CollectibleSponsor.collectibleSponsor_schema import CollectibleSponsorResponse
from api.exceptions import NotFoundException

def getCollectibleSponsorById(
    collectibleSponsorId: int = Query(..., description="ID of the collectible sponsor record to retrieve"),
    db: Session = Depends(get_db)
) -> CollectibleSponsorResponse:
    """
    Retrieves a collectible sponsor record by its collectibleSponsorId using SQLAlchemy.
    """
    db_collectible_sponsor = db.query(CollectibleSponsor).filter(CollectibleSponsor.collectibleSponsorId == collectibleSponsorId).first()
    if db_collectible_sponsor is None:
        raise NotFoundException(detail=f"CollectibleSponsor record with ID {collectibleSponsorId} not found")
    return db_collectible_sponsor

def getCollectibleSponsorByCollectibleId(
    collectibleId: int = Query(..., description="ID of the collectible to retrieve sponsor records for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CollectibleSponsorResponse]:
    """
    Retrieves collectible sponsor records by collectible ID, with pagination.
    """
    collectible_sponsors = db.query(CollectibleSponsor).filter(CollectibleSponsor.collectibleId == collectibleId).offset(skip).limit(limit).all()
    return collectible_sponsors

def getCollectibleSponsorBySponsorId(
    sponsorId: int = Query(..., description="ID of the sponsor to retrieve collectible sponsor records for"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CollectibleSponsorResponse]:
    """
    Retrieves collectible sponsor records by sponsor ID, with pagination.
    """
    collectible_sponsors = db.query(CollectibleSponsor).filter(CollectibleSponsor.sponsorId == sponsorId).offset(skip).limit(limit).all()
    return collectible_sponsors
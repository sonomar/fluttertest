from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import DistributionCollectible
from database.schema.GET.DistributionCollectible.distributionCollectible_schema import DistributionCollectibleResponse
from api.exceptions import NotFoundException

def getDistributionCollectibleByDistributionCollectibleId(
    distributionCollectibleId: int,
    db: Session = Depends(get_db)
) -> DistributionCollectibleResponse:
    db_distribution_collectible = db.query(DistributionCollectible).filter(DistributionCollectible.distributionCollectibleId == distributionCollectibleId).first()
    if db_distribution_collectible is None:
        raise NotFoundException(detail=f"DistributionCollectible with ID {distributionCollectibleId} not found")
    return db_distribution_collectible

def getAllDistributionCollectibles(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
) -> List[DistributionCollectibleResponse]:
    return db.query(DistributionCollectible).offset(skip).limit(limit).all()

def getDistributionCollectiblesByDistributionId(
    distributionId: int,
    db: Session = Depends(get_db)
) -> List[DistributionCollectibleResponse]:
    return db.query(DistributionCollectible).filter(DistributionCollectible.distributionId == distributionId).all()

def getDistributionCollectiblesByCollectibleId(
    collectibleId: int,
    db: Session = Depends(get_db)
) -> List[DistributionCollectibleResponse]:
    return db.query(DistributionCollectible).filter(DistributionCollectible.collectibleId == collectibleId).all()
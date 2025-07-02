from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import Distribution
from database.schema.GET.Distribution.distribution_schema import DistributionResponse
from api.exceptions import NotFoundException

def getDistributionByDistributionId(
    distributionId: int,
    db: Session = Depends(get_db)
) -> DistributionResponse:
    db_distribution = db.query(Distribution).filter(Distribution.distributionId == distributionId).first()
    if db_distribution is None:
        raise NotFoundException(detail=f"Distribution with ID {distributionId} not found")
    return db_distribution

def getAllDistributions(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
) -> List[DistributionResponse]:
    return db.query(Distribution).offset(skip).limit(limit).all()
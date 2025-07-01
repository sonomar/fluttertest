from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import DistributionCode
from database.schema.GET.DistributionCode.distributionCode_schema import DistributionCodeResponse
from api.exceptions import NotFoundException

def getDistributionCodeByDistributionCodeId(
    distributionCodeId: int,
    db: Session = Depends(get_db)
) -> DistributionCodeResponse:
    db_distribution_code = db.query(DistributionCode).filter(DistributionCode.distributionCodeId == distributionCodeId).first()
    if db_distribution_code is None:
        raise NotFoundException(detail=f"DistributionCode with ID {distributionCodeId} not found")
    return db_distribution_code

def getAllDistributionCodes(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
) -> List[DistributionCodeResponse]:
    return db.query(DistributionCode).offset(skip).limit(limit).all()
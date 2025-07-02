from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import DistributionCodeUser
from database.schema.GET.DistributionCodeUser.distributionCodeUser_schema import DistributionCodeUserResponse
from api.exceptions import NotFoundException

def getDistributionCodeUserByDistributionCodeUserId(
    distributionCodeUserId: int,
    db: Session = Depends(get_db)
) -> DistributionCodeUserResponse:
    db_distribution_code_user = db.query(DistributionCodeUser).filter(DistributionCodeUser.distributionCodeUserId == distributionCodeUserId).first()
    if db_distribution_code_user is None:
        raise NotFoundException(detail=f"DistributionCodeUser with ID {distributionCodeUserId} not found")
    return db_distribution_code_user

def getAllDistributionCodeUsers(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
) -> List[DistributionCodeUserResponse]:
    return db.query(DistributionCodeUser).offset(skip).limit(limit).all()
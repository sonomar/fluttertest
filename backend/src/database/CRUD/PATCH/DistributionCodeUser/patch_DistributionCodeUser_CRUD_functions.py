from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import DistributionCodeUser
from database.schema.PATCH.DistributionCodeUser.distributionCodeUser_schema import DistributionCodeUserUpdate
from api.exceptions import NotFoundException, BadRequestException

def updateDistributionCodeUserByDistributionCodeUserId(
    distributionCodeUserId: int,
    distribution_code_user: DistributionCodeUserUpdate,
    db: Session = Depends(get_db)
):
    db_distribution_code_user = db.query(DistributionCodeUser).filter(DistributionCodeUser.distributionCodeUserId == distributionCodeUserId).first()
    if not db_distribution_code_user:
        raise NotFoundException(detail=f"DistributionCodeUser with ID {distributionCodeUserId} not found")

    update_data = distribution_code_user.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_distribution_code_user, key, value)

    try:
        db.commit()
        db.refresh(db_distribution_code_user)
        return db_distribution_code_user
    except IntegrityError as e:
        db.rollback()
        raise BadRequestException(detail=f"Database integrity error: {e}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
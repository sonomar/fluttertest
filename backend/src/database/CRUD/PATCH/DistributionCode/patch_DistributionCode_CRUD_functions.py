from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import DistributionCode
from database.schema.PATCH.DistributionCode.distributionCode_schema import DistributionCodeUpdate
from api.exceptions import NotFoundException, BadRequestException, ConflictException

def updateDistributionCodeByDistributionCodeId(
    distributionCodeId: int,
    distribution_code: DistributionCodeUpdate,
    db: Session = Depends(get_db)
):
    db_distribution_code = db.query(DistributionCode).filter(DistributionCode.distributionCodeId == distributionCodeId).first()
    if not db_distribution_code:
        raise NotFoundException(detail=f"DistributionCode with ID {distributionCodeId} not found")

    update_data = distribution_code.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_distribution_code, key, value)

    try:
        db.commit()
        db.refresh(db_distribution_code)
        return db_distribution_code
    except IntegrityError as e:
        db.rollback()
        if 'Duplicate entry' in str(e) and "'code'" in str(e):
            raise ConflictException(detail=f"Distribution code already exists.")
        raise BadRequestException(detail=f"Database integrity error: {e}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
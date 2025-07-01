from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import DistributionCode
from database.schema.POST.DistributionCode.distributionCode_schema import DistributionCodeCreate
from api.exceptions import ConflictException, BadRequestException

def createDistributionCode(
    distribution_code: DistributionCodeCreate,
    db: Session = Depends(get_db)
):
    """
    Adds a new distribution code to the database using SQLAlchemy.
    """
    db_distribution_code = DistributionCode(
        distributionId=distribution_code.distributionId,
        code=distribution_code.code,
        qrCode=distribution_code.qrCode,
        isMultiUse=distribution_code.isMultiUse,
        multiUseQty=distribution_code.multiUseQty
    )

    try:
        db.add(db_distribution_code)
        db.commit()
        db.refresh(db_distribution_code)
        return db_distribution_code
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        if 'Duplicate entry' in error_message and "'code'" in error_message:
            raise ConflictException(detail=f"Distribution code '{distribution_code.code}' already exists.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
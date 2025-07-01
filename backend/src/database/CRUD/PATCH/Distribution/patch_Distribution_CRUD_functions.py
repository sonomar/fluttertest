from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Distribution
from database.schema.PATCH.Distribution.distribution_schema import DistributionUpdate
from api.exceptions import NotFoundException, BadRequestException

def updateDistributionByDistributionId(
    distributionId: int,
    distribution: DistributionUpdate,
    db: Session = Depends(get_db)
):
    db_distribution = db.query(Distribution).filter(Distribution.distributionId == distributionId).first()
    if not db_distribution:
        raise NotFoundException(detail=f"Distribution with ID {distributionId} not found")

    update_data = distribution.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_distribution, key, value)

    try:
        db.commit()
        db.refresh(db_distribution)
        return db_distribution
    except IntegrityError as e:
        db.rollback()
        raise BadRequestException(detail=f"Database integrity error: {e}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
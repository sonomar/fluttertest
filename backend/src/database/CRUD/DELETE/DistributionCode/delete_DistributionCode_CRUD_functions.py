from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session

from database.db import get_db
from database.models import DistributionCode
from api.exceptions import NotFoundException

def deleteDistributionCodeByDistributionCodeId(
    distributionCodeId: int,
    db: Session = Depends(get_db)
):
    db_distribution_code = db.query(DistributionCode).filter(DistributionCode.distributionCodeId == distributionCodeId).first()
    if not db_distribution_code:
        raise NotFoundException(detail=f"DistributionCode with ID {distributionCodeId} not found")

    try:
        db.delete(db_distribution_code)
        db.commit()
        return {"message": f"DistributionCode with ID {distributionCodeId} deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
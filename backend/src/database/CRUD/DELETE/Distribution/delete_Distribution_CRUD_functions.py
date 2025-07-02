from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session

from database.db import get_db
from database.models import Distribution
from api.exceptions import NotFoundException

def deleteDistributionByDistributionId(
    distributionId: int,
    db: Session = Depends(get_db)
):
    db_distribution = db.query(Distribution).filter(Distribution.distributionId == distributionId).first()
    if not db_distribution:
        raise NotFoundException(detail=f"Distribution with ID {distributionId} not found")

    try:
        db.delete(db_distribution)
        db.commit()
        return {"message": f"Distribution with ID {distributionId} deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
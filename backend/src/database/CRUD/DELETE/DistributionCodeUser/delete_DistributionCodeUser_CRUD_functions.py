from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session

from database.db import get_db
from database.models import DistributionCodeUser
from api.exceptions import NotFoundException

def deleteDistributionCodeUserByDistributionCodeUserId(
    distributionCodeUserId: int,
    db: Session = Depends(get_db)
):
    db_distribution_code_user = db.query(DistributionCodeUser).filter(DistributionCodeUser.distributionCodeUserId == distributionCodeUserId).first()
    if not db_distribution_code_user:
        raise NotFoundException(detail=f"DistributionCodeUser with ID {distributionCodeUserId} not found")

    try:
        db.delete(db_distribution_code_user)
        db.commit()
        return {"message": f"DistributionCodeUser with ID {distributionCodeUserId} deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
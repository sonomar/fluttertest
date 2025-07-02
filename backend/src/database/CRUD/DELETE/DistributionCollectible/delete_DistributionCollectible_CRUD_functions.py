from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session

from database.db import get_db
from database.models import DistributionCollectible
from api.exceptions import NotFoundException

def deleteDistributionCollectibleByDistributionCollectibleId(
    distributionCollectibleId: int,
    db: Session = Depends(get_db)
):
    db_distribution_collectible = db.query(DistributionCollectible).filter(DistributionCollectible.distributionCollectibleId == distributionCollectibleId).first()
    if not db_distribution_collectible:
        raise NotFoundException(detail=f"DistributionCollectible with ID {distributionCollectibleId} not found")

    try:
        db.delete(db_distribution_collectible)
        db.commit()
        return {"message": f"DistributionCollectible with ID {distributionCollectibleId} deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
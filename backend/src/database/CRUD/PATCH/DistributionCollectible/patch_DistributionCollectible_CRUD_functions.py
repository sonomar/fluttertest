from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import DistributionCollectible
from database.schema.PATCH.DistributionCollectible.distributionCollectible_schema import DistributionCollectibleUpdate
from api.exceptions import NotFoundException, BadRequestException

def updateDistributionCollectibleByDistributionCollectibleId(
    distributionCollectibleId: int,
    distribution_collectible: DistributionCollectibleUpdate,
    db: Session = Depends(get_db)
):
    db_distribution_collectible = db.query(DistributionCollectible).filter(DistributionCollectible.distributionCollectibleId == distributionCollectibleId).first()
    if not db_distribution_collectible:
        raise NotFoundException(detail=f"DistributionCollectible with ID {distributionCollectibleId} not found")

    update_data = distribution_collectible.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_distribution_collectible, key, value)

    try:
        db.commit()
        db.refresh(db_distribution_collectible)
        return db_distribution_collectible
    except IntegrityError as e:
        db.rollback()
        raise BadRequestException(detail=f"Database integrity error: {e}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
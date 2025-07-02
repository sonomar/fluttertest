from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import DistributionCollectible
from database.schema.POST.DistributionCollectible.distributionCollectible_schema import DistributionCollectibleCreate
from api.exceptions import BadRequestException

def createDistributionCollectible(
    distribution_collectible: DistributionCollectibleCreate,
    db: Session = Depends(get_db)
):
    """
    Adds a new distribution collectible to the database using SQLAlchemy.
    """
    db_distribution_collectible = DistributionCollectible(
        collectibleId=distribution_collectible.collectibleId,
        distributionId=distribution_collectible.distributionId
    )

    try:
        db.add(db_distribution_collectible)
        db.commit()
        db.refresh(db_distribution_collectible)
        return db_distribution_collectible
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
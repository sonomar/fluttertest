from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Distribution
from database.schema.POST.Distribution.distribution_schema import DistributionCreate
from api.exceptions import BadRequestException

def createDistribution(
    distribution: DistributionCreate,
    db: Session = Depends(get_db)
):
    """
    Adds a new distribution to the database using SQLAlchemy.
    """
    db_distribution = Distribution(
        projectId=distribution.projectId,
        collectionId=distribution.collectionId,
        name=distribution.name,
        type=distribution.type,
        description=distribution.description,
        isTimed=distribution.isTimed,
        isLimited=distribution.isLimited,
        isNewUserReward=distribution.isNewUserReward,
        limitedQty=distribution.limitedQty,
        isRandom=distribution.isRandom,
        startDate=distribution.startDate,
        endDate=distribution.endDate,
        isUniqueCollectible=distribution.isUniqueCollectible
    )

    try:
        db.add(db_distribution)
        db.commit()
        db.refresh(db_distribution)
        return db_distribution
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
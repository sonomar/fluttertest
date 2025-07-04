from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import DistributionCodeUser
from database.schema.POST.DistributionCodeUser.distributionCodeUser_schema import DistributionCodeUserCreate
from api.exceptions import BadRequestException

def createDistributionCodeUser(
    distribution_code_user: DistributionCodeUserCreate,
    db: Session = Depends(get_db)
):
    """
    Adds a new distribution code user to the database using SQLAlchemy.
    """
    db_distribution_code_user = DistributionCodeUser(
        userId=distribution_code_user.userId,
        distributionCodeId=distribution_code_user.distributionCodeId,
        previousOwnerId=distribution_code_user.previousOwnerId,
        redeemed=distribution_code_user.redeemed,
        redeemedDate=distribution_code_user.redeemedDate,
        collectibleReceived=distribution_code_user.collectibleReceived
    )

    try:
        db.add(db_distribution_code_user)
        db.commit()
        db.refresh(db_distribution_code_user)
        return db_distribution_code_user
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
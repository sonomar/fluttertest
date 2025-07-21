from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Purchase
from database.schema.POST.Purchase.purchase_schema import PurchaseCreate
from database.schema.GET.Purchase.purchase_schema import PurchaseResponse
from api.exceptions import BadRequestException

def createPurchase(
    purchase: PurchaseCreate,
    db: Session = Depends(get_db)
) -> PurchaseResponse:
    """
    Adds a new purchase to the database using SQLAlchemy.
    """
    db_purchase = Purchase(
        **purchase.model_dump()
    )

    try:
        db.add(db_purchase)
        db.commit()
        db.refresh(db_purchase)
        return PurchaseResponse.model_validate(db_purchase)
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
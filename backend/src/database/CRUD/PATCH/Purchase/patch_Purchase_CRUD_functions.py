from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Purchase
from database.schema.PATCH.Purchase.purchase_schema import PurchaseUpdate
from database.schema.GET.Purchase.purchase_schema import PurchaseResponse
from api.exceptions import NotFoundException, BadRequestException

def updatePurchaseByPurchaseId(
    purchaseId: int = Path(..., description="ID of the purchase to update"),
    purchase_update_data: PurchaseUpdate = Body(..., description="Data to update purchase"),
    db: Session = Depends(get_db)
) -> PurchaseResponse:
    db_purchase = db.query(Purchase).filter(Purchase.purchaseId == purchaseId).first()

    if db_purchase is None:
        raise NotFoundException(detail=f"Purchase with ID {purchaseId} not found")

    update_data = purchase_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(db_purchase, field, value)

    try:
        db.commit()
        db.refresh(db_purchase)
        return db_purchase
    except IntegrityError as e:
        db.rollback()
        raise BadRequestException(detail=f"Database integrity error: {e}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
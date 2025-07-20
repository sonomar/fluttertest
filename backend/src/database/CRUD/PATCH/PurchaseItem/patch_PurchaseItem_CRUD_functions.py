from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import PurchaseItem
from database.schema.PATCH.PurchaseItem.purchaseItem_schema import PurchaseItemUpdate
from database.schema.GET.PurchaseItem.purchaseItem_schema import PurchaseItemResponse
from api.exceptions import NotFoundException, BadRequestException

def updatePurchaseItemByPurchaseItemId(
    purchaseItemId: int = Path(..., description="ID of the purchase item to update"),
    purchase_item_update_data: PurchaseItemUpdate = Body(..., description="Data to update purchase item"),
    db: Session = Depends(get_db)
) -> PurchaseItemResponse:
    db_purchase_item = db.query(PurchaseItem).filter(PurchaseItem.purchaseItemId == purchaseItemId).first()

    if db_purchase_item is None:
        raise NotFoundException(detail=f"PurchaseItem with ID {purchaseItemId} not found")

    update_data = purchase_item_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(db_purchase_item, field, value)

    try:
        db.commit()
        db.refresh(db_purchase_item)
        return db_purchase_item
    except IntegrityError as e:
        db.rollback()
        raise BadRequestException(detail=f"Database integrity error: {e}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
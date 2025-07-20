from fastapi import Depends, HTTPException, status, Path
from sqlalchemy.orm import Session
from typing import Dict

from database.db import get_db
from database.models import PurchaseItem
from api.exceptions import NotFoundException

def deletePurchaseItemByPurchaseItemId(
    purchaseItemId: int = Path(..., description="ID of the purchase item to delete"),
    db: Session = Depends(get_db)
) -> Dict[str, str]:
    db_purchase_item = db.get(PurchaseItem, purchaseItemId)
    if db_purchase_item is None:
        raise NotFoundException(detail=f"PurchaseItem with ID {purchaseItemId} not found")
    try:
        db.delete(db_purchase_item)
        db.commit()
        return {"message": f"PurchaseItem with ID {purchaseItemId} deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
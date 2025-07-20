from fastapi import Depends, HTTPException, status, Path
from sqlalchemy.orm import Session
from typing import Dict

from database.db import get_db
from database.models import Purchase
from api.exceptions import NotFoundException

def deletePurchaseByPurchaseId(
    purchaseId: int = Path(..., description="ID of the purchase to delete"),
    db: Session = Depends(get_db)
) -> Dict[str, str]:
    db_purchase = db.get(Purchase, purchaseId)
    if db_purchase is None:
        raise NotFoundException(detail=f"Purchase with ID {purchaseId} not found")
    try:
        db.delete(db_purchase)
        db.commit()
        return {"message": f"Purchase with ID {purchaseId} deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
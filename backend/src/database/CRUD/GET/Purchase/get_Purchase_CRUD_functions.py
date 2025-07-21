from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import Purchase
from database.schema.GET.Purchase.purchase_schema import PurchaseResponse
from api.exceptions import NotFoundException

def getPurchaseByPurchaseId(
    purchaseId: int,
    db: Session = Depends(get_db)
) -> PurchaseResponse:
    db_purchase = db.query(Purchase).filter(Purchase.purchaseId == purchaseId).first()
    if db_purchase is None:
        raise NotFoundException(detail=f"Purchase with ID {purchaseId} not found")
    return db_purchase

def getPurchasesByUserId(
    userId: int,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
) -> List[PurchaseResponse]:
    return db.query(Purchase).filter(Purchase.userId == userId).offset(skip).limit(limit).all()
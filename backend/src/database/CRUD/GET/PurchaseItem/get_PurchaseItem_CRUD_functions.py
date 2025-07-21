from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import PurchaseItem
from database.schema.GET.PurchaseItem.purchaseItem_schema import PurchaseItemResponse

def getPurchaseItemsByPurchaseId(
    purchaseId: int,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
) -> List[PurchaseItemResponse]:
    return db.query(PurchaseItem).filter(PurchaseItem.purchaseId == purchaseId).offset(skip).limit(limit).all()
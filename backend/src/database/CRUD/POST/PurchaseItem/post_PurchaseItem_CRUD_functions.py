from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import PurchaseItem
from database.schema.POST.PurchaseItem.purchaseItem_schema import PurchaseItemCreate
from api.exceptions import BadRequestException

def createPurchaseItem(
    purchase_item: PurchaseItemCreate,
    db: Session = Depends(get_db)
):
    """
    Adds a new purchase item to the database using SQLAlchemy.
    """
    db_purchase_item = PurchaseItem(
        **purchase_item.model_dump()
    )

    try:
        db.add(db_purchase_item)
        db.commit()
        db.refresh(db_purchase_item)
        return db_purchase_item
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
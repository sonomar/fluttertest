from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

class PurchaseItemResponse(BaseModel):
    purchaseItemId: int
    purchaseId: int
    itemTable: str
    itemId: int
    blockchainData: Optional[Dict[str, Any]] = None
    purchasedUserItemId: Optional[int] = None
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
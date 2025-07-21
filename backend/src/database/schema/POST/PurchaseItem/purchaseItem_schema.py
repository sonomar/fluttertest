from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from database.models import ItemTableEnum

class PurchaseItemCreate(BaseModel):
    purchaseId: int
    itemTable: ItemTableEnum
    itemId: int
    blockchainData: Optional[Dict[str, Any]] = None
    purchasedUserItemId: Optional[int] = None
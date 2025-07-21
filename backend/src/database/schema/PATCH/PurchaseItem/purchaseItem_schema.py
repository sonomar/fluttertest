from pydantic import BaseModel
from typing import Optional, Dict, Any

class PurchaseItemUpdate(BaseModel):
    purchaseId: Optional[int] = None
    itemTable: Optional[str] = None
    itemId: Optional[int] = None
    blockchainData: Optional[Dict[str, Any]] = None
    purchasedUserItemId: Optional[int] = None
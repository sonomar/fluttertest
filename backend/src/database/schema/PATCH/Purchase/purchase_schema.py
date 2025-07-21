from pydantic import BaseModel
from typing import Optional, Dict, Any
from database.models import PurchaseCurrencyEnum, PurchaseStatusEnum

class PurchaseUpdate(BaseModel):
    userId: Optional[int] = None
    currency: Optional[PurchaseCurrencyEnum] = None
    status: Optional[PurchaseStatusEnum] = None
    messages: Optional[Dict[str, Any]] = None
    purchaseData: Optional[Dict[str, Any]] = None
    blockchainPaymentData: Optional[Dict[str, Any]] = None
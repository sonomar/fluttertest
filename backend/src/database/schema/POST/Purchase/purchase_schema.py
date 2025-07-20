from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from database.models import PurchaseCurrencyEnum, PurchaseStatusEnum

class PurchaseCreate(BaseModel):
    userId: int
    currency: PurchaseCurrencyEnum
    status: PurchaseStatusEnum
    messages: Optional[Dict[str, Any]] = None
    purchaseData: Optional[Dict[str, Any]] = None
    blockchainPaymentData: Optional[Dict[str, Any]] = None
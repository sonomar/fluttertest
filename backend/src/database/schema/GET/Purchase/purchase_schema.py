from pydantic import BaseModel
from typing import Optional, List, Dict, Any
import datetime
from database.models import PurchaseCurrencyEnum, PurchaseStatusEnum
from database.schema.GET.PurchaseItem.purchaseItem_schema import PurchaseItemResponse

class PurchaseResponse(BaseModel):
    purchaseId: int
    userId: int
    currency: PurchaseCurrencyEnum
    status: PurchaseStatusEnum
    messages: Optional[Dict[str, Any]] = None
    purchaseData: Optional[Dict[str, Any]] = None
    blockchainPaymentData: Optional[Dict[str, Any]] = None
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
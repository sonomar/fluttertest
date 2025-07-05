from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

class DistributionCodeUserCreate(BaseModel):
    userId: int
    distributionCodeId: int
    previousOwnerId: Optional[int] = None
    redeemed: bool
    redeemedDate: Optional[datetime.datetime] = None
    collectibleReceived: Optional[Dict[str, Any]] = None
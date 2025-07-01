from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

class DistributionCodeUserUpdate(BaseModel):
    userId: Optional[int] = None
    distributionCodeId: Optional[int] = None
    previousOwnerId: Optional[int] = None
    redeemed: Optional[bool] = None
    redeemedDate: Optional[datetime.datetime] = None
    collectibleRevieved: Optional[Dict[str, Any]] = None
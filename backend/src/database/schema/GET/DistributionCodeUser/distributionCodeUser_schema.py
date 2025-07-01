from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

class DistributionCodeUserResponse(BaseModel):
    distributionCodeUserId: int
    userId: int
    distributionCodeId: int
    previousOwnerId: Optional[int] = None
    redeemed: bool
    redeemedDate: Optional[datetime.datetime] = None
    collectibleRevieved: Optional[Dict[str, Any]] = None
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
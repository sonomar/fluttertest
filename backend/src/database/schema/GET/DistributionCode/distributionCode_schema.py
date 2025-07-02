from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

class DistributionCodeResponse(BaseModel):
    distributionCodeId: int
    distributionId: int
    code: str
    qrCode: Optional[Dict[str, Any]] = None
    isMultiUse: bool
    multiUseQty: Optional[int] = None
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
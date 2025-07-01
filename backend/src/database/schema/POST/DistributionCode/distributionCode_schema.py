from pydantic import BaseModel
from typing import Optional, Dict, Any

class DistributionCodeCreate(BaseModel):
    distributionId: int
    code: str
    qrCode: Optional[Dict[str, Any]] = None
    isMultiUse: bool
    multiUseQty: Optional[int] = None
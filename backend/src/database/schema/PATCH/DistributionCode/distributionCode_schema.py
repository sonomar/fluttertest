from pydantic import BaseModel
from typing import Optional, Dict, Any

class DistributionCodeUpdate(BaseModel):
    distributionId: Optional[int] = None
    code: Optional[str] = None
    qrCode: Optional[Dict[str, Any]] = None
    isMultiUse: Optional[bool] = None
    multiUseQty: Optional[int] = None
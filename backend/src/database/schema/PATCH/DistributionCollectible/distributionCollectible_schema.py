from pydantic import BaseModel
from typing import Optional

class DistributionCollectibleUpdate(BaseModel):
    collectibleId: Optional[int] = None
    distributionId: Optional[int] = None
from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime
from database.models import DistributionTypeEnum

class DistributionCreate(BaseModel):
    projectId: int
    collectionId: Optional[int] = None
    name: Dict[str, Any]
    type: DistributionTypeEnum
    description: Optional[Dict[str, Any]] = None
    isTimed: bool
    isLimited: bool
    isNewUserReward: bool
    limitedQty: Optional[int] = None
    isRandom: bool
    startDate: datetime.datetime
    endDate: datetime.datetime
    isUniqueCollectible: Optional[bool] = None
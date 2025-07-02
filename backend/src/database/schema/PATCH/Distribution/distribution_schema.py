from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime
from database.models import DistributionTypeEnum

class DistributionUpdate(BaseModel):
    projectId: Optional[int] = None
    collectionId: Optional[int] = None
    name: Optional[Dict[str, Any]] = None
    type: Optional[DistributionTypeEnum] = None
    description: Optional[Dict[str, Any]] = None
    isTimed: Optional[bool] = None
    isLimited: Optional[bool] = None
    isNewUserReward: Optional[bool] = None
    limitedQty: Optional[int] = None
    isRandom: Optional[bool] = None
    startDate: Optional[datetime.datetime] = None
    endDate: Optional[datetime.datetime] = None
    isUniqueCollectible: Optional[bool] = None
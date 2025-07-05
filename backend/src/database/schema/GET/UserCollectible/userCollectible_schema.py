from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

# Schema for getting a  UserCollectible(all fields optional)
class UserCollectibleResponse(BaseModel):
    userCollectibleId: int
    ownerId: int
    collectibleId: int
    mint: int
    previousOwnerId: Optional[int] = None
    lastTransferredDt: Optional[datetime.datetime] = None
    active: Optional[bool] = True
    favorite: Optional[bool] = False
    trade: Optional[bool] = None
    points: Optional[int] = None
    qrCode: Optional[Dict[str, Any]] = None
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
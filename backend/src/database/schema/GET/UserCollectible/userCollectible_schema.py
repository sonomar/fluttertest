from pydantic import BaseModel
from typing import Optional
import datetime

# Schema for getting a  UserCollectible(all fields optional)
class UserCollectibleResponse(BaseModel):
    userCollectibleId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime
    ownerId: int
    collectibleId: int
    mint: int # Mint number is part of the unique key
    previousOwnerId: Optional[int] = None
    lastTransferredDt: Optional[datetime.datetime] = None
    active: Optional[bool] = True
    favorite: Optional[bool] = False

    class Config:
        from_attributes = True
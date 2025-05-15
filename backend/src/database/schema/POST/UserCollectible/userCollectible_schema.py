from pydantic import BaseModel
from typing import Optional
import datetime

class UserCollectibleCreate(BaseModel):
    ownerId: int
    collectibleId: int
    mint: int # Mint number is part of the unique key
    previousOwnerId: Optional[int] = None
    lastTransferredDt: Optional[datetime.datetime] = None
    active: Optional[bool] = True
    favorite: Optional[bool] = False
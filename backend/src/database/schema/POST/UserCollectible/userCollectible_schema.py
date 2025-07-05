from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

class UserCollectibleCreate(BaseModel):
    ownerId: int
    collectibleId: int
    mint: int
    previousOwnerId: Optional[int] = None
    lastTransferredDt: Optional[datetime.datetime] = None
    active: Optional[bool] = True
    favorite: Optional[bool] = False
    trade: Optional[bool] = False
    points: Optional[int] = 0
    qrCode: Optional[Dict[str, Any]] = None
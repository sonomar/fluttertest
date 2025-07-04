from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

class UserCollectibleUpdate(BaseModel):
    ownerId: Optional[int] = None
    collectibleId: Optional[int] = None
    mint: Optional[int] = None
    previousOwnerId: Optional[int] = None
    lastTransferredDt: Optional[datetime.datetime] = None
    active: Optional[bool] = None
    favorite: Optional[bool] = None
    trade: Optional[bool] = None
    points: Optional[int] = None
    qrCode: Optional[Dict[str, Any]] = None
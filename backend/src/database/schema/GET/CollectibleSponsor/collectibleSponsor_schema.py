from pydantic import BaseModel
from typing import Optional, Dict, Any

# --- CollectibleSponsor Schemas ---
class CollectibleSponsorResponse(BaseModel):
    collectibleSponsorId: int
    collectibleId: int
    sponsorId: int
    sponsorMessage: Optional[str] = None
    active: Optional[bool] = True

    class Config:
        from_attributes = True
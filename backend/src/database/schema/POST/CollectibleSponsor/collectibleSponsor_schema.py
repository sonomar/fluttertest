from pydantic import BaseModel
from typing import Optional, Dict, Any

# --- CollectibleSponsor Schemas ---
class CollectibleSponsorCreate(BaseModel):
    collectibleId: int
    sponsorId: int
    sponsorMessage: Optional[Dict[str, str]] = None
    active: Optional[bool] = True
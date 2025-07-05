from pydantic import BaseModel
from typing import Optional, Dict, Any

# --- CollectibleSponsor Schemas ---
class CollectibleSponsorUpdate(BaseModel):
    collectibleId: Optional[int] = None
    sponsorId: Optional[int] = None
    sponsorMessage: Optional[Dict[str, str]] = None
    active: Optional[bool] = None
from pydantic import BaseModel
from typing import Optional, Dict
import datetime

# --- CommunityUser Schemas ---
class CommunityUserResponse(BaseModel):
    communityUserId: int
    communityId: int
    memberId: int
    completed: Optional[Dict[str, str]] = None
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
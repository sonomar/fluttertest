from pydantic import BaseModel
from typing import Optional

# --- CommunityUser Schemas ---
class CommunityUserUpdate(BaseModel):
    communityId: Optional[int] = None
    memberId: Optional[int] = None
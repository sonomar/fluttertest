from pydantic import BaseModel
from typing import Optional, Dict

class CommunityUserUpdate(BaseModel):
    communityId: Optional[int] = None
    memberId: Optional[int] = None
    completed: Optional[Dict[str, str]] = None
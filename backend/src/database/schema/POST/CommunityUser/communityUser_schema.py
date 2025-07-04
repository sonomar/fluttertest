from pydantic import BaseModel
from typing import Optional, Dict

class CommunityUserCreate(BaseModel):
    communityId: int
    memberId: int
    completed: Optional[Dict[str, str]] = None
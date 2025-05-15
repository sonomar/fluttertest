from pydantic import BaseModel, Field
from typing import Optional

# --- MissionUserData Schemas ---
class MissionUserDataCreate(BaseModel):
    missionUserId: int
    action: Optional[str] = None
    status: Optional[str] = None
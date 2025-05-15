from pydantic import BaseModel
from typing import Optional

# --- MissionUserData Schemas ---
class MissionUserDataUpdate(BaseModel):
    missionUserId: Optional[int] = None
    action: Optional[str] = None
    status: Optional[str] = None
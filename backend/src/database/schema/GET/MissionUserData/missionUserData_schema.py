from pydantic import BaseModel
from typing import Optional
import datetime

# --- MissionUserData Schemas ---
class MissionUserDataResponse(BaseModel):
    missionUserDataId: int
    createdDt: datetime.datetime

    missionUserId: int
    action: Optional[str] = None
    status: Optional[str] = None

    class Config:
        from_attributes = True
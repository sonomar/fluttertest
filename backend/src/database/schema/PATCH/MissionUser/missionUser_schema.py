from pydantic import BaseModel
from typing import Optional
import datetime

# --- MissionUser Schemas ---
class MissionUserUpdate(BaseModel):
    userId: Optional[int] = None
    missionId: Optional[int] = None
    progress: Optional[int] = None
    status: Optional[str] = None
    completed: Optional[bool] = None
    dateCompleted: Optional[datetime.datetime] = None
    rewardClaimed: Optional[bool] = None
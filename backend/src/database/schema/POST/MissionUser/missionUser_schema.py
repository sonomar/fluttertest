from pydantic import BaseModel
from typing import Optional
import datetime

# --- MissionUser Schemas ---
class MissionUserCreate(BaseModel):
    userId: int
    missionId: int
    progress: Optional[int] = 0
    status: Optional[str] = None
    completed: Optional[bool] = False
    dateCompleted: Optional[datetime.datetime] = None
    rewardClaimed: Optional[bool] = False
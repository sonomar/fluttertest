from pydantic import BaseModel
from typing import Optional

class MissionTypeResponse(BaseModel):
    missionTypeId: int
    name: str
    description: Optional[str] = None

    class Config:
        from_attributes = True
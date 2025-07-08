from pydantic import BaseModel
from typing import Optional

class MissionTypeCreate(BaseModel):
    name: str
    description: Optional[str] = None
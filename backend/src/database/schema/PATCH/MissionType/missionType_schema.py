from pydantic import BaseModel
from typing import Optional

class MissionTypeUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
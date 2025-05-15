from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

class ProjectResponse(BaseModel):
    projectId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    name: str
    attributed: Dict[str, Any] # Assuming attributed is always a dict
    location: Optional[str] = None
    active: Optional[bool] = True

    class Config:
        from_attributes = True
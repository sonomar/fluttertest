from pydantic import BaseModel
from typing import Optional, Dict, Any
import datetime

class ProjectResponse(BaseModel):
    projectId: int
    name: Dict[str, str]
    attributed: Dict[str, Any]
    location: Optional[str] = None
    active: Optional[bool] = True
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
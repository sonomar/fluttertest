from pydantic import BaseModel
from typing import Optional, Dict, Any

class ProjectCreate(BaseModel):
    name: Dict[str, str]
    attributed: Dict[str, Any]
    location: Optional[str] = None
    active: Optional[bool] = True
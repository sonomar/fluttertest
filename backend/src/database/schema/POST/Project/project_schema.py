from pydantic import BaseModel
from typing import Optional, Dict, Any

class ProjectCreate(BaseModel):
    name: str
    attributed: Dict[str, Any] # Assuming attributed is always a dict
    location: Optional[str] = None
    active: Optional[bool] = True
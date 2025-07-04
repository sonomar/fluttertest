from pydantic import BaseModel
from typing import Optional, Dict, Any

class ProjectUpdate(BaseModel):
    name: Optional[Dict[str, str]] = None
    attributed: Optional[Dict[str, Any]] = None
    location: Optional[str] = None
    active: Optional[bool] = None
from pydantic import BaseModel
from typing import Optional

# --- Category Schemas ---
class CategoryUpdate(BaseModel):
    name: Optional[str] = None
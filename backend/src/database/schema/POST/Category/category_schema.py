from pydantic import BaseModel

# --- Category Schemas ---
class CategoryCreate(BaseModel):
    name: str
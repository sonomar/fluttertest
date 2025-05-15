from pydantic import BaseModel
import datetime

# --- Category Schemas ---
class CategoryResponse(BaseModel):
    categoryId: int
    name: str
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
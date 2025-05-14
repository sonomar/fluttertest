from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Dict, Any, List
import datetime
from database.schemas_common import UserBase # Adjust import path if necessary

# Schema for returning User data (excludes sensitive info like passwordHash)
class UserResponse(UserBase):
    userId: int
    active: bool
    userRank: Optional[Dict[str, Any]] = None # JSON field
    userType: Optional[str] = None # Return user type as string
    createdDt: datetime.datetime
    updatedDt: datetime.datetime
    lastLoggedIn: Optional[datetime.datetime] = None

    class Config:
        from_attributes = True # Enables ORM mode
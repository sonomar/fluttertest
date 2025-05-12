from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Dict, Any, List
import datetime
from database.schemas_common import UserBase # Adjust import path if necessary
from database.models import UserTypeEnum # Adjust import path if necessary

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
        orm_mode = True # Enables ORM mode

# Schema for creating a User (includes password)
class UserCreate(UserBase):
    passwordHashed: str # Password provided during creation
    userType: Optional[UserTypeEnum]
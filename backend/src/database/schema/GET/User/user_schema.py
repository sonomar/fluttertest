from pydantic import BaseModel, EmailStr
from typing import Optional, Dict, Any
import datetime


# Schema for returning User data (excludes sensitive info like passwordHash)
class UserResponse(BaseModel):
    userId: int
    email: EmailStr
    username: Optional[str] = None
    profileImg: Optional[str] = None
    deviceId: Optional[str] = None
    active: bool
    userRank: Optional[Dict[str, Any]] = None # JSON field
    userType: Optional[str] = None # Return user type as string
    createdDt: datetime.datetime
    updatedDt: datetime.datetime
    lastLoggedIn: Optional[datetime.datetime] = None

    class Config:
        from_attributes = True # Enables ORM mode

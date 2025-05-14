from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Dict, Any, List
import datetime
from database.schemas_common import UserBase # Adjust import path if necessary
from database.models import UserTypeEnum

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

# Schema for updating a User (all fields optional)
class UserUpdate(UserBase):
    # Inherits base fields, make them optional for update
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    profileImg: Optional[str] = None
    deviceId: Optional[str] = None
    # Don't include password here usually. If password update is separate, use another schema.
    passwordHashed: Optional[str] = None
    userRank: Optional[Dict[str, Any]] = None # Allow updating JSON field
    active: Optional[bool] = None # Allow updating active status
    userType: Optional[str] = None # Allow updating user type (as string input)
    lastLoggedIn: Optional[datetime.datetime] = None # Allow updating last login time
    authToken: Optional[str] = None # Allow updating auth token
    userType: Optional[UserTypeEnum]
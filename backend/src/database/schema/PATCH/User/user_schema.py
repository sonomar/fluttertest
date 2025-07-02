from pydantic import EmailStr, BaseModel
from typing import Optional, Dict, Any
import datetime
from database.models import UserTypeEnum


# Schema for updating a User (all fields optional)
class UserUpdate(BaseModel):
    # Inherits base fields, make them optional for update
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    profileImg: Optional[str] = None
    deviceId: Optional[str] = None
    # Don't include password here usually. If password update is separate, use another schema.
    passwordHashed: Optional[str] = None
    userRank: Optional[Dict[str, Any]] = None # Allow updating JSON field
    active: Optional[bool] = None # Allow updating active status
    lastLoggedIn: Optional[datetime.datetime] = None # Allow updating last login time
    authToken: Optional[str] = None # Allow updating auth token
    userType: Optional[UserTypeEnum] = None
    pushToken: Optional[str] = None
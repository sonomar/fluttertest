from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from database.models import UserTypeEnum # Adjust import path if necessary


# Schema for creating a User (includes password)
class UserCreate(BaseModel):
    email: EmailStr
    username: Optional[str] = None
    profileImg: Optional[str] = None
    deviceId: Optional[str] = None
    passwordHashed: str # Password provided during creation
    userType: Optional[UserTypeEnum]
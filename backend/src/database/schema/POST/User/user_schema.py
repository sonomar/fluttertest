from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Dict
from database.models import UserTypeEnum

class UserCreate(BaseModel):
    email: EmailStr
    username: Optional[str] = None
    cognitoUsername: Optional[str] = None
    profileImg: Optional[str] = None
    deviceId: Optional[str] = None
    passwordHashed: str
    userType: Optional[UserTypeEnum] = Field(default=UserTypeEnum.onboarding)
    authToken: Optional[str] = None
    authData: Optional[Dict] = None
    pushToken: Optional[str] = None
    score: Optional[int] = 0
    isOnBlockchain: Optional[bool] = False
    blockchainUserAddress: Optional[str] = None

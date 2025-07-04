from pydantic import BaseModel, EmailStr
from typing import Optional, Dict, Any
import datetime

class UserResponse(BaseModel):
    userId: int
    email: EmailStr
    username: Optional[str] = None
    profileImg: Optional[str] = None
    deviceId: Optional[str] = None
    active: bool
    userRank: Optional[Dict[str, Any]] = None
    userType: Optional[str] = None
    createdDt: datetime.datetime
    updatedDt: datetime.datetime
    lastLoggedIn: Optional[datetime.datetime] = None
    score: Optional[int] = None
    cognitoUsername: Optional[str] = None
    isOnBlockchain: Optional[bool] = None
    blockchainUserAddress: Optional[str] = None
    pushToken: Optional[str] = None
    authData: Optional[Dict] = None

    class Config:
        from_attributes = True

    
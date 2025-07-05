from pydantic import EmailStr, BaseModel
from typing import Optional, Dict, Any
import datetime
from database.models import UserTypeEnum

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    username: Optional[str] = None
    cognitoUsername: Optional[str] = None
    profileImg: Optional[str] = None
    deviceId: Optional[str] = None
    passwordHashed: Optional[str] = None
    userRank: Optional[Dict[str, Any]] = None
    active: Optional[bool] = None
    lastLoggedIn: Optional[datetime.datetime] = None
    authToken: Optional[str] = None
    authData: Optional[Dict] = None
    userType: Optional[UserTypeEnum] = None
    pushToken: Optional[str] = None
    score: Optional[int] = None
    isOnBlockchain: Optional[bool] = None
    blockchainUserAddress: Optional[str] = None
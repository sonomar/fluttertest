from pydantic import EmailStr, BaseModel
from typing import Optional, Dict, Any
import datetime

# Schema for getting a Sponsor (all fields optional)
class SponsorResponse(BaseModel):
    sponsorId: int
    name: str
    organization: Optional[str] = None
    urls: Optional[Dict[str, Any]] = None
    description: Optional[str] = None
    imageRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    sponsorCity: Optional[str] = None
    sponsorCountry: Optional[str] = None
    sponsorZip: Optional[str] = None
    primaryContactName: Optional[str] = None
    primaryContactEmail: Optional[EmailStr] = None
    primaryContactPhone: Optional[int] = None # Using int for BIGINT
    active: Optional[bool] = True
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
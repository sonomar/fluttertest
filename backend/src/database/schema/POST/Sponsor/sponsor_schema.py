from pydantic import BaseModel, EmailStr
from typing import Optional, Dict, Any

# Schema for creating Sponsor data
class SponsorCreate(BaseModel):
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
from pydantic import EmailStr, BaseModel
from typing import Optional, Dict, Any, Union, List
import datetime

# Schema for getting a Sponsor (all fields optional)
class SponsorResponse(BaseModel):
    sponsorId: int
    name: str
    organization: Optional[str] = None
    urls: Optional[Dict[str, Any]] = None
    description: Optional[str] = None
    imageRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    vidRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    qrRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
    embedRef: Optional[Union[Dict[str, Any], str, List[str]]] = None
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
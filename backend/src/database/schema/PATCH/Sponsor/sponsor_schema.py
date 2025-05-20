from pydantic import EmailStr, BaseModel
from typing import Optional, Dict, Any, Union, List

# Schema for updating a Sponsor (all fields optional)
class SponsorUpdate(BaseModel):
    name: Optional[str] = None
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
    primaryContactPhone: Optional[int] = None
    active: Optional[bool] = None
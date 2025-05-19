# database/CRUD/GET/Sponsor/get_Sponsor_CRUD_functions.py
from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List

from database.db import get_db
from database.models import Sponsor
from database.schema.GET.Sponsor.sponsor_schema import SponsorResponse
from api.exceptions import NotFoundException

def getSponsorById(
    sponsorId: int = Query(..., description="ID of the sponsor to retrieve"),
    db: Session = Depends(get_db)
) -> SponsorResponse:
    db_sponsor = db.query(Sponsor).filter(Sponsor.sponsorId == sponsorId).first()
    if db_sponsor is None:
        raise NotFoundException(detail=f"Sponsor with ID {sponsorId} not found")
    return db_sponsor

def getSponsorByName(
    name: str = Query(..., description="Name of the sponsor to retrieve"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[SponsorResponse]:
    sponsors = db.query(Sponsor).filter(Sponsor.name.ilike(f"%{name}%")).offset(skip).limit(limit).all()
    return sponsors

def getSponsorByOrganization(
    organization: str = Query(..., description="Organization of the sponsor to retrieve"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[SponsorResponse]:
    sponsors = db.query(Sponsor).filter(Sponsor.organization.ilike(f"%{organization}%")).offset(skip).limit(limit).all()
    return sponsors
# database/CRUD/POST/Sponsor/post_Sponsor_table.py
from tools.prod.prodTools import extractData
from database.schema.POST.Sponsor.sponsor_schema import SponsorCreate
import database.CRUD.POST.Sponsor.post_Sponsor_CRUD_functions as crudFunctions

def create_sponsor(event):
    """
    Adds a new sponsor to the database.
    Requires 'name'. Other fields are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "name" not in data:
        return {
            "statusCode": 400,
            "body": "name is required"
        }

    # Create Pydantic model instance
    sponsor = SponsorCreate(
        name=data["name"],
        organization=data.get("organization"),
        urls=data.get("urls"),
        description=data.get("description"),
        imageRef=data.get("imageRef"),
        vidRef=data.get("vidRef"),
        qrRef=data.get("qrRef"),
        embedRef=data.get("embedRef"),
        sponsorCity=data.get("sponsorCity"),
        sponsorCountry=data.get("sponsorCountry"),
        sponsorZip=data.get("sponsorZip"),
        primaryContactName=data.get("primaryContactName"),
        primaryContactEmail=data.get("primaryContactEmail"),
        primaryContactPhone=data.get("primaryContactPhone"),
        active=data.get("active") # Schema default is True if not provided
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.create_sponsor(sponsor=sponsor, db=event["db_session"])
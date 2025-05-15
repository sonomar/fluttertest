from tools.prod.prodTools import extractData
import database.CRUD.PATCH.Sponsor.patch_Sponsor_CRUD_functions as crudFunctions
from database.schema.PATCH.Sponsor.sponsor_schema import SponsorUpdate

def SponsorDataCheck(sponsor: SponsorUpdate, data: any):
    if "name" in data:
        sponsor.name = data["name"]
    if "organization" in data:
        sponsor.organization = data["organization"]
    if "urls" in data:
        sponsor.urls = data["urls"]
    if "description" in data:
        sponsor.description = data["description"]
    if "imageRef" in data:
        sponsor.imageRef = data["imageRef"]
    if "vidRef" in data:
        sponsor.vidRef = data["vidRef"]
    if "qrRef" in data:
        sponsor.qrRef = data["qrRef"]
    if "embedRef" in data:
        sponsor.embedRef = data["embedRef"]
    if "sponsorCity" in data:
        sponsor.sponsorCity = data["sponsorCity"]
    if "sponsorCountry" in data:
        sponsor.sponsorCountry = data["sponsorCountry"]
    if "sponsorZip" in data:
        sponsor.sponsorZip = data["sponsorZip"]
    if "primaryContactName" in data:
        sponsor.primaryContactName = data["primaryContactName"]
    if "primaryContactEmail" in data:
        sponsor.primaryContactEmail = data["primaryContactEmail"]
    if "primaryContactPhone" in data:
        sponsor.primaryContactPhone = data["primaryContactPhone"]
    if "active" in data:
        sponsor.active = data["active"]
    return sponsor

def updateSponsorBySponsorId(event):
    data = extractData(event)
    if not data or "sponsorId" not in data:
        return {'statusCode': 400, 'body': 'sponsorId is required'}

    sponsor_id = data["sponsorId"]
    sponsor = SponsorUpdate()
    sponsor = SponsorDataCheck(sponsor, data)
    return crudFunctions.updateSponsorBySponsorId(sponsorId=sponsor_id, sponsor_update_data=sponsor, db=event['db_session'])
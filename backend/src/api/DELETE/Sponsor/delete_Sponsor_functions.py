from tools.prod.prodTools import extractData
import database.CRUD.DELETE.Sponsor.delete_Sponsor_CRUD_functions as crudFunctions



def deleteSponsorBySponsorId(event):
    """
    Deletes a Sponsor record by sponsorId.
    Requires 'sponsorId'.
    """
    data = extractData(event)
    if not data or "sponsorId" not in data:
        return {'statusCode': 400, 'body': 'sponsorId is required'}

    sponsor_id = data["sponsorId"]
    return crudFunctions.deleteSponsorBySponsorId(sponsorId=sponsor_id,db=event['db_session'])
from tools.prod.prodTools import extractData
import database.CRUD.DELETE.CollectibleSponsor.delete_CollectibleSponsor_CRUD_functions as crudFunctions


def deleteCollectibleSponsorByCollectibleSponsorId(event):
    """
    Deletes a CollectibleSponsor record by collectibleSponsorId.
    Requires 'collectibleSponsorId'.
    """
    data = extractData(event)
    if not data or "collectibleSponsorId" not in data:
        return {'statusCode': 400, 'body': 'collectibleSponsorId is required'}

    collectibleSponsor_id = data["collectibleSponsorId"]
    return crudFunctions.deleteCollectibleSponsorByCollectibleSponsorId(collectibleSponsorId=collectibleSponsor_id,db=event['db_session'])
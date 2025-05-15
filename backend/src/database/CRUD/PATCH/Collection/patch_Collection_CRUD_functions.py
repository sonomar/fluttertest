from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Collection
from database.schema.PATCH.Collection.collection_schema import CollectionUpdate
from database.schema.GET.Collection.collection_schema import CollectionResponse
from api.exceptions import NotFoundException, ConflictException, BadRequestException

def updateCollectionByCollectionId(
    collectionId: int = Path(..., description="ID of the collection to update"),
    collection_update_data: CollectionUpdate = Body(..., description="Data to update collection"),
    db: Session = Depends(get_db)
) -> CollectionResponse:
    db_collection = db.query(Collection).filter(Collection.collectionId == collectionId).first()

    if db_collection is None:
        raise NotFoundException(detail=f"Collection with ID {collectionId} not found")

    update_data = collection_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_collection, field):
            setattr(db_collection, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on Collection model.")

    try:
        db.commit()
        db.refresh(db_collection)
        return db_collection
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating collection {collectionId}: {error_message}")
        if 'Duplicate entry' in error_message and "'name'" in error_message and "'communityId'":
            raise ConflictException(detail=f"Collection name already exists within this community.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating collection {collectionId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
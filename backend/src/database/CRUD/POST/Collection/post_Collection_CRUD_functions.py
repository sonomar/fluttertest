from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Collection
from database.schema.POST.Collection.collection_schema import CollectionCreate
from database.schema.GET.Collection.collection_schema import CollectionResponse # Updated import
from api.exceptions import BadRequestException

def create_collection(
    collection: CollectionCreate,
    db: Session = Depends(get_db)
) -> CollectionResponse: # Updated return type
    """
    Adds a new collection to the database using SQLAlchemy.
    """
    db_collection = Collection(
        communityId=collection.communityId,
        name=collection.name,
        description=collection.description,
        imageRef=collection.imageRef,
        vidRef=collection.vidRef,
        qrRef=collection.qrRef,
        embedRef=collection.embedRef,
        active=collection.active
    )

    try:
        db.add(db_collection)
        db.commit()
        db.refresh(db_collection)
        return CollectionResponse.model_validate(db_collection) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating collection: {error_message}")
        # Add specific checks if there are unique constraints on collection fields
        raise BadRequestException(detail=f"Database integrity error: {e}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating collection: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Collectible
from database.schema.POST.Collectible.collectible_schema import CollectibleCreate
from database.schema.GET.Collectible.collectible_schema import CollectibleResponse # Updated import
from api.exceptions import ConflictException, BadRequestException

def createCollectible(
    collectible: CollectibleCreate,
    db: Session = Depends(get_db)
) -> CollectibleResponse: # Updated return type
    """
    Adds a new collectible to the database using SQLAlchemy.
    """
    db_collectible = Collectible(
        collectionId=collectible.collectionId,
        categoryId=collectible.categoryId,
        projectId=collectible.projectId,
        communityId=collectible.communityId,
        label=collectible.label,
        name=collectible.name,
        description=collectible.description,
        imageRef=collectible.imageRef,
        vidRef=collectible.vidRef,
        qrRef=collectible.qrRef,
        embedRef=collectible.embedRef,
        circulation=collectible.circulation,
        publicationDate=collectible.publicationDate,
        active=collectible.active
    )

    try:
        db.add(db_collectible)
        db.commit()
        db.refresh(db_collectible)
        return CollectibleResponse.model_validate(db_collectible) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating collectible: {error_message}")
        # Add specific checks if there are unique constraints on collectible fields
        raise BadRequestException(detail=f"Database integrity error: {e}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating collectible: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
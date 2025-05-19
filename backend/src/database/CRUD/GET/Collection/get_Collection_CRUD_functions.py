# database/CRUD/GET/Collection/get_Collection_CRUD_functions.py
from fastapi import Depends, Query, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from database.db import get_db
from database.models import Collection
from database.schema.GET.Collection.collection_schema import CollectionResponse
from api.exceptions import NotFoundException

def getCollectionById(
    collectionId: int = Query(..., description="ID of the collection to retrieve"),
    db: Session = Depends(get_db)
) -> CollectionResponse:
    db_collection = db.query(Collection).filter(Collection.collectionId == collectionId).first()
    if db_collection is None:
        raise NotFoundException(detail=f"Collection with ID {collectionId} not found")
    return db_collection

def getCollectionByName(
    name: str = Query(..., description="Name of the collection to retrieve"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[CollectionResponse]:
    collections = db.query(Collection).filter(Collection.name.ilike(f"%{name}%")).offset(skip).limit(limit).all()
    return collections
# src/api/GET/User/get_User_functions.py
# Remove pymysql and old tools imports
# from tools.prod.prodTools import extractData, get_connection # REMOVED


# Import the database session dependency and models/schemas
from fastapi import Depends, HTTPException, status, Path # Added FastAPI dependencies
from sqlalchemy.orm import Session # Added SQLAlchemy Session type
from typing import Dict # Added typing hints

# Import the database session dependency and models
from database.db import get_db # Adjust import path if necessary
from database.models import Project # Adjust import path if necessary

# Import custom exceptions
from api.exceptions import NotFoundException # Adjust import path

# --- Refactored Function using SQLAlchemy ORM ---

# Make function async if using an async driver, otherwise sync is fine with Depends
# Keeping sync for now to match previous examples

def deleteProjectByProjectId(
    projectId: int = Path(..., description="ID of the project to delete"),
    db: Session = Depends(get_db)
) -> Dict[str, str]:
    db_project = db.get(Project, projectId)
    if db_project is None:
        raise NotFoundException(detail=f"Project with ID {projectId} not found")
    try:
        db.delete(db_project)
        db.commit()
        return {"message": f"Project with ID {projectId} deleted successfully"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
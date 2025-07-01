from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from database.db import get_db
from database.models import Project
from database.schema.POST.Project.project_schema import ProjectCreate
# Assuming a GET/Project/project_schema.py exists or similar naming
from database.schema.GET.Project.project_schema import ProjectResponse # Updated import for response schema
from api.exceptions import BadRequestException

def createProject(
    project: ProjectCreate,
    db: Session = Depends(get_db)
) -> ProjectResponse: # Updated return type
    """
    Adds a new project to the database using SQLAlchemy.
    """
    db_project = Project(
        name=project.name,
        attributed=project.attributed,
        location=project.location,
        active=project.active
    )

    try:
        db.add(db_project)
        db.commit()
        db.refresh(db_project)
        return ProjectResponse.model_validate(db_project) # Updated return statement
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error creating project: {error_message}")
        # Add specific checks if there are unique constraints on project fields
        raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error creating project: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
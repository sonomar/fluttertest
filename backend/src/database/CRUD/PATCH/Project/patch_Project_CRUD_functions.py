from fastapi import Depends, HTTPException, status, Path, Body
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Dict, Any

from database.db import get_db
from database.models import Project
from database.schema.PATCH.Project.project_schema import ProjectUpdate
from database.schema.GET.Project.project_schema import ProjectResponse
from api.exceptions import NotFoundException, ConflictException, BadRequestException

def updateProjectByProjectId(
    projectId: int = Path(..., description="ID of the project to update"),
    project_update_data: ProjectUpdate = Body(..., description="Data to update project"),
    db: Session = Depends(get_db)
) -> ProjectResponse:
    db_project = db.query(Project).filter(Project.projectId == projectId).first()

    if db_project is None:
        raise NotFoundException(detail=f"Project with ID {projectId} not found")

    update_data = project_update_data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(db_project, field):
            setattr(db_project, field, value)
        else:
            print(f"Warning: Field '{field}' in update data does not exist on Project model.")

    try:
        db.commit()
        db.refresh(db_project)
        return db_project
    except IntegrityError as e:
        db.rollback()
        error_message = str(e)
        print(f"Integrity error updating project {projectId}: {error_message}")
        if 'Duplicate entry' in error_message and "'name'" in error_message:
            raise ConflictException(detail=f"Project name already exists.")
        else:
            raise BadRequestException(detail=f"Database integrity error: {error_message}")
    except Exception as e:
        db.rollback()
        print(f"Database error updating project {projectId}: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Database error: {e}")
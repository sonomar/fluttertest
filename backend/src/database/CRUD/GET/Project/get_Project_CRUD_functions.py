# database/CRUD/GET/Project/get_Project_CRUD_functions.py
from fastapi import Depends, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from database.db import get_db
from database.models import Project
from database.schema.GET.Project.project_schema import ProjectResponse
from api.exceptions import NotFoundException

def getProjectByProjectId(
    projectId: int = Query(..., description="ID of the project to retrieve"),
    db: Session = Depends(get_db)
) -> ProjectResponse:
    """
    Retrieves a project by its projectId using SQLAlchemy.
    """
    db_project = db.query(Project).filter(Project.projectId == projectId).first()
    if db_project is None:
        raise NotFoundException(detail=f"Project with ID {projectId} not found")
    return db_project

def getProjectByName(
    name: str = Query(..., description="Name of the project to retrieve"),
    skip: int = Query(0, description="Skip this many items"),
    limit: int = Query(100, description="Limit results to this many items"),
    db: Session = Depends(get_db)
) -> List[ProjectResponse]:
    """
    Retrieves projects by their name using SQLAlchemy, with pagination.
    """
    projects = db.query(Project).filter(Project.name.ilike(f"%{name}%")).offset(skip).limit(limit).all()
    return projects
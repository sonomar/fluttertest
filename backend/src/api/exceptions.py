# src/api/exceptions.py
from fastapi import HTTPException, status

# Custom exception for items not found
class NotFoundException(HTTPException):
    def __init__(self, detail: str = "Item not found"):
        super().__init__(status_code=status.HTTP_404_NOT_FOUND, detail=detail)

# Custom exception for conflicts (e.g., duplicate entry)
class ConflictException(HTTPException):
    def __init__(self, detail: str = "Conflict"):
        super().__init__(status_code=status.HTTP_409_CONFLICT, detail=detail)

# Custom exception for bad requests (validation errors, missing data etc.)
class BadRequestException(HTTPException):
     def __init__(self, detail: str = "Bad Request"):
         super().__init__(status_code=status.HTTP_400_BAD_REQUEST, detail=detail)

# Add other custom exceptions as needed
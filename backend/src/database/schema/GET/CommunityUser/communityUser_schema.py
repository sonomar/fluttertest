from pydantic import BaseModel
import datetime

# --- CommunityUser Schemas ---
class CommunityUserResponse(BaseModel):
    communityUserId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime
    communityId: int
    memberId: int

    class Config:
        from_attributes = True
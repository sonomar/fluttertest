from pydantic import BaseModel

# --- CommunityUser Schemas ---
class CommunityUserCreate(BaseModel):
    communityId: int
    memberId: int
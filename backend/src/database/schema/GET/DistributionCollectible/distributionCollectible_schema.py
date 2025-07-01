from pydantic import BaseModel
import datetime

class DistributionCollectibleResponse(BaseModel):
    distributionCollectibleId: int
    collectibleId: int
    distributionId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        from_attributes = True
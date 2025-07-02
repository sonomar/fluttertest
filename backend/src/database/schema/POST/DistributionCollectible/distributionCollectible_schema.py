from pydantic import BaseModel

class DistributionCollectibleCreate(BaseModel):
    collectibleId: int
    distributionId: int
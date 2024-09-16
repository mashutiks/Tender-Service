from pydantic import BaseModel
from typing import List, Optional

class Organization(BaseModel):
    name: str
    description: str
    type: str
class Tender(BaseModel):
    name: str
    description: str
    serviceType: str
    status: str
    organizationId: int 
    creatorUsername: str
    
class TenderUpdate(BaseModel):
    name: str
    description: str

class Proposal(BaseModel):
    name: str
    description: str
    status: str
    tender_id: int
    organization_id: int  # Используем целое число для ID организации
    creator_username: str
    
class ProposalUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    
class Review(BaseModel):
    author_username: str
    organization_id: int
    review_text: str
    
class ReviewFilters(BaseModel):
    author_username: Optional[str] = None
    organization_id: Optional[int] = None
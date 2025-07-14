from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List, Union

# Request schemas
class CreateNoteRequest(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    content: str = Field(..., min_length=1)
    color: Optional[str] = Field(None, pattern="^#[0-9A-Fa-f]{6}$")

class UpdateNoteRequest(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    content: Optional[str] = Field(None, min_length=1)
    color: Optional[str] = Field(None, pattern="^#[0-9A-Fa-f]{6}$")

# Response schemas
class NoteResponse(BaseModel):
    id: str
    title: str
    content: str
    color: Optional[str] = None
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True

# API Response wrapper - matches frontend expectations
class ApiResponse(BaseModel):
    success: bool
    data: Optional[Union[NoteResponse, List[NoteResponse], bool]] = None
    error: Optional[str] = None
    message: Optional[str] = None
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from database import get_db
from schemas import (
    CreateNoteRequest, 
    UpdateNoteRequest, 
    NoteResponse, 
    ApiResponse
)
import crud

router = APIRouter(tags=["notes"])

def format_note_response(note) -> NoteResponse:
    """Convert database Note model to NoteResponse schema"""
    return NoteResponse(
        id=str(note.id),
        title=note.title,
        content=note.content,
        color=note.color,
        created_at=note.created_at.isoformat(),
        updated_at=note.updated_at.isoformat()
    )

@router.get("/notes", response_model=ApiResponse)
async def get_all_notes(db: Session = Depends(get_db)):
    """Get all notes - GET /api/notes"""
    try:
        notes = crud.get_notes(db)
        notes_response = [format_note_response(note) for note in notes]
        return ApiResponse(
            success=True,
            data=notes_response
        )
    except Exception as e:
        return ApiResponse(
            success=False,
            error=str(e)
        )

@router.post("/notes", response_model=ApiResponse)
async def create_note(
    note_data: CreateNoteRequest, 
    db: Session = Depends(get_db)
):
    """Create a new note - POST /api/notes"""
    try:
        new_note = crud.create_note(db, note_data)
        note_response = format_note_response(new_note)
        return ApiResponse(
            success=True,
            data=note_response,
            message="Note created successfully"
        )
    except Exception as e:
        return ApiResponse(
            success=False,
            error=str(e)
        )

@router.put("/notes/{note_id}", response_model=ApiResponse)
async def update_note(
    note_id: int,
    note_data: UpdateNoteRequest,
    db: Session = Depends(get_db)
):
    """Update an existing note - PUT /api/notes/{id}"""
    try:
        updated_note = crud.update_note(db, note_id, note_data)
        if not updated_note:
            return ApiResponse(
                success=False,
                error="Note not found"
            )
        
        note_response = format_note_response(updated_note)
        return ApiResponse(
            success=True,
            data=note_response,
            message="Note updated successfully"
        )
    except Exception as e:
        return ApiResponse(
            success=False,
            error=str(e)
        )

@router.delete("/notes/{note_id}", response_model=ApiResponse)
async def delete_note(
    note_id: int,
    db: Session = Depends(get_db)
):
    """Delete a note - DELETE /api/notes/{id}"""
    try:
        success = crud.delete_note(db, note_id)
        if not success:
            return ApiResponse(
                success=False,
                error="Note not found"
            )
        
        return ApiResponse(
            success=True,
            data=True,
            message="Note deleted successfully"
        )
    except Exception as e:
        return ApiResponse(
            success=False,
            error=str(e)
        )

@router.get("/notes/{note_id}", response_model=ApiResponse)
async def get_note(
    note_id: int,
    db: Session = Depends(get_db)
):
    """Get a single note by ID - GET /api/notes/{id}"""
    try:
        note = crud.get_note_by_id(db, note_id)
        if not note:
            return ApiResponse(
                success=False,
                error="Note not found"
            )
        
        note_response = format_note_response(note)
        return ApiResponse(
            success=True,
            data=note_response
        )
    except Exception as e:
        return ApiResponse(
            success=False,
            error=str(e)
        )
from sqlalchemy.orm import Session
from sqlalchemy import desc
from models import Note
from schemas import CreateNoteRequest, UpdateNoteRequest
from typing import List, Optional

def get_notes(db: Session) -> List[Note]:
    """Get all notes ordered by created_at descending"""
    return db.query(Note).order_by(desc(Note.created_at)).all()

def get_note_by_id(db: Session, note_id: int) -> Optional[Note]:
    """Get a single note by ID"""
    return db.query(Note).filter(Note.id == note_id).first()

def create_note(db: Session, note: CreateNoteRequest) -> Note:
    """Create a new note"""
    db_note = Note(
        title=note.title,
        content=note.content,
        color=note.color
    )
    db.add(db_note)
    db.commit()
    db.refresh(db_note)
    return db_note

def update_note(db: Session, note_id: int, note_update: UpdateNoteRequest) -> Optional[Note]:
    """Update an existing note"""
    db_note = get_note_by_id(db, note_id)
    if not db_note:
        return None
    
    # Only update fields that are provided
    update_data = note_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_note, field, value)
    
    db.commit()
    db.refresh(db_note)
    return db_note

def delete_note(db: Session, note_id: int) -> bool:
    """Delete a note by ID"""
    db_note = get_note_by_id(db, note_id)
    if not db_note:
        return False
    
    db.delete(db_note)
    db.commit()
    return True
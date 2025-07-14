import { Note, CreateNoteRequest, UpdateNoteRequest, DeleteNoteRequest, ApiResponse } from '@/types/note';

// Backend API Configuration
const API_BASE_URL = process.env.NODE_ENV === 'production' 
  ? 'https://your-production-domain.com/api'
  : 'http://localhost:8000/api';

class NoteService {
  /**
   * Fetch all notes from backend
   * Backend endpoint: GET /api/notes
   */
  async getAllNotes(): Promise<ApiResponse<Note[]>> {
    try {
      const response = await fetch(`${API_BASE_URL}/notes`);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error fetching notes:', error);
      return {
        success: false,
        error: 'Failed to fetch notes'
      };
    }
  }

  /**
   * Create a new note
   * Backend endpoint: POST /api/notes
   */
  async createNote(noteData: CreateNoteRequest): Promise<ApiResponse<Note>> {
    try {
      const response = await fetch(`${API_BASE_URL}/notes`, {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(noteData)
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error creating note:', error);
      return {
        success: false,
        error: 'Failed to create note'
      };
    }
  }

  /**
   * Update an existing note
   * Backend endpoint: PUT /api/notes/{id}
   */
  async updateNote(noteData: UpdateNoteRequest): Promise<ApiResponse<Note>> {
    try {
      const { id, ...updateData } = noteData;
      const response = await fetch(`${API_BASE_URL}/notes/${id}`, {
        method: 'PUT',
        headers: { 
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(updateData)
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error updating note:', error);
      return {
        success: false,
        error: 'Failed to update note'
      };
    }
  }

  /**
   * Delete a note
   * Backend endpoint: DELETE /api/notes/{id}
   */
  async deleteNote(noteData: DeleteNoteRequest): Promise<ApiResponse<boolean>> {
    try {
      const response = await fetch(`${API_BASE_URL}/notes/${noteData.id}`, {
        method: 'DELETE'
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error deleting note:', error);
      return {
        success: false,
        error: 'Failed to delete note'
      };
    }
  }
}

export const noteService = new NoteService();
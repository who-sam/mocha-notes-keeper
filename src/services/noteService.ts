import { Note, CreateNoteRequest, UpdateNoteRequest, DeleteNoteRequest, ApiResponse } from '@/types/note';

// Backend API Configuration
// TODO: Replace with your actual AWS EC2 domain
const API_BASE_URL = 'https://your-ec2-domain.com/api';

// Mock data for development - remove when connecting to real backend
const mockNotes: Note[] = [
  {
    id: '1',
    title: 'Welcome to Notes',
    content: 'This is a sample note. Click to edit or create new notes!',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    color: '#f9e2af'
  },
  {
    id: '2',
    title: 'Backend Integration',
    content: 'Connect to your Python backend by updating the API_BASE_URL in noteService.ts',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    color: '#fab387'
  }
];

class NoteService {
  // TODO: Implement real API calls to your Python backend
  
  /**
   * Fetch all notes from backend
   * Backend endpoint: GET /api/notes
   */
  async getAllNotes(): Promise<ApiResponse<Note[]>> {
    try {
      // TODO: Replace with actual API call
      // const response = await fetch(`${API_BASE_URL}/notes`);
      // const data = await response.json();
      
      // Mock implementation
      await new Promise(resolve => setTimeout(resolve, 500)); // Simulate network delay
      return {
        success: true,
        data: mockNotes
      };
    } catch (error) {
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
      // TODO: Replace with actual API call
      // const response = await fetch(`${API_BASE_URL}/notes`, {
      //   method: 'POST',
      //   headers: { 'Content-Type': 'application/json' },
      //   body: JSON.stringify(noteData)
      // });
      // const data = await response.json();

      // Mock implementation
      const newNote: Note = {
        id: Date.now().toString(),
        ...noteData,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
      mockNotes.push(newNote);
      
      return {
        success: true,
        data: newNote
      };
    } catch (error) {
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
      // TODO: Replace with actual API call
      // const response = await fetch(`${API_BASE_URL}/notes/${noteData.id}`, {
      //   method: 'PUT',
      //   headers: { 'Content-Type': 'application/json' },
      //   body: JSON.stringify(noteData)
      // });
      // const data = await response.json();

      // Mock implementation
      const noteIndex = mockNotes.findIndex(note => note.id === noteData.id);
      if (noteIndex === -1) {
        return {
          success: false,
          error: 'Note not found'
        };
      }

      const updatedNote = {
        ...mockNotes[noteIndex],
        ...noteData,
        updated_at: new Date().toISOString()
      };
      mockNotes[noteIndex] = updatedNote;

      return {
        success: true,
        data: updatedNote
      };
    } catch (error) {
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
      // TODO: Replace with actual API call
      // const response = await fetch(`${API_BASE_URL}/notes/${noteData.id}`, {
      //   method: 'DELETE'
      // });
      // const data = await response.json();

      // Mock implementation
      const noteIndex = mockNotes.findIndex(note => note.id === noteData.id);
      if (noteIndex === -1) {
        return {
          success: false,
          error: 'Note not found'
        };
      }

      mockNotes.splice(noteIndex, 1);

      return {
        success: true,
        data: true
      };
    } catch (error) {
      return {
        success: false,
        error: 'Failed to delete note'
      };
    }
  }
}

export const noteService = new NoteService();
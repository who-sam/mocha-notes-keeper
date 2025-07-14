// Note data structure - matches what your Python backend will provide
export interface Note {
  id: string;           // Backend: UUID or auto-increment ID
  title: string;        // Backend: VARCHAR(255)
  content: string;      // Backend: TEXT
  created_at: string;   // Backend: TIMESTAMP (ISO format)
  updated_at: string;   // Backend: TIMESTAMP (ISO format)
  color?: string;       // Backend: VARCHAR(7) for hex colors (optional)
}

// API request/response types for backend integration
export interface CreateNoteRequest {
  title: string;
  content: string;
  color?: string;
}

export interface UpdateNoteRequest {
  id: string;
  title?: string;
  content?: string;
  color?: string;
}

export interface DeleteNoteRequest {
  id: string;
}

// API response wrapper
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}
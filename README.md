# Notes App - Google Keep Clone

A minimal, clean note-taking application built with React, TypeScript, and Catppuccin Mocha color palette.

## ✨ Features

- **Create, Edit, Delete** notes with timestamps
- **Color-coded** notes for better organization
- **Search functionality** across title and content
- **Responsive design** with beautiful Catppuccin Mocha theme
- **Clean file structure** ready for backend integration

## 🎨 Design

- **Catppuccin Mocha** color palette for a beautiful dark theme
- **Google Keep-inspired** layout and interaction patterns
- **Responsive grid** that adapts to different screen sizes
- **Smooth animations** and hover effects

## 📁 File Structure

```
src/
├── types/
│   └── note.ts                 # Note interface & API types
├── services/
│   └── noteService.ts          # Backend API service layer
├── components/
│   └── notes/
│       ├── NoteCard.tsx        # Individual note display
│       ├── NoteEditor.tsx      # Create/edit note modal
│       └── NotesGrid.tsx       # Notes grid layout
├── pages/
│   └── Index.tsx               # Main app page
└── components/ui/              # Shadcn UI components
```

## 🔌 Backend Integration

The frontend is ready for your Python backend! Update these files:

### 1. Update API Base URL

In `src/services/noteService.ts`:
```typescript
// Replace with your AWS EC2 domain
const API_BASE_URL = 'https://your-ec2-domain.com/api';
```

### 2. Database Schema (MariaDB)

Create a table with this structure:
```sql
CREATE TABLE notes (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    color VARCHAR(7)  -- Optional: hex color codes
);
```

### 3. Python Backend API Endpoints

Your Python backend should implement these endpoints:

#### GET /api/notes
- Returns all notes for the user
- Response: `{ "success": true, "data": [...notes] }`

#### POST /api/notes  
- Creates a new note
- Body: `{ "title": "string", "content": "string", "color": "string?" }`
- Response: `{ "success": true, "data": {...note} }`

#### PUT /api/notes/{id}
- Updates an existing note  
- Body: `{ "title": "string?", "content": "string?", "color": "string?" }`
- Response: `{ "success": true, "data": {...note} }`

#### DELETE /api/notes/{id}
- Deletes a note
- Response: `{ "success": true, "data": true }`

### 4. Error Handling

All endpoints should return errors in this format:
```json
{
  "success": false,
  "error": "Error message here"
}
```

## 🚀 Development

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Start development server**:
   ```bash
   npm run dev
   ```

3. **Backend Integration**:
   - The app currently uses mock data for development
   - All API calls are clearly marked with `TODO` comments
   - Simply uncomment the real API calls and remove mock implementations

## 📝 Usage

- **Create Note**: Click the "New Note" button
- **Edit Note**: Click on any note card
- **Delete Note**: Hover over a note and click the trash icon
- **Search**: Use the search bar to find notes by title or content
- **Colors**: Choose from 8 beautiful Catppuccin colors when editing

## 🎯 Next Steps

1. Deploy your Python backend to AWS EC2
2. Update the `API_BASE_URL` in noteService.ts
3. Remove mock data and enable real API calls
4. Test all CRUD operations
5. Deploy the frontend to your preferred hosting platform

The frontend is fully functional with mock data and ready to connect to your backend!

---

## Project info

**URL**: https://lovable.dev/projects/3227bc58-a5d7-404d-98a0-cfe8e94beaee

## How can I deploy this project?

Simply open [Lovable](https://lovable.dev/projects/3227bc58-a5d7-404d-98a0-cfe8e94beaee) and click on Share -> Publish.

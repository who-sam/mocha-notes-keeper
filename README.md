# Notes App - Full Stack Application

A complete note-taking application with React TypeScript frontend and FastAPI Python backend.

## ✨ Features

- **Full CRUD Operations** - Create, read, update, delete notes
- **Color-coded Notes** for better organization
- **Search Functionality** across title and content
- **Responsive Design** with beautiful Catppuccin Mocha theme
- **Real-time API** with FastAPI backend
- **SQLite Database** with SQLAlchemy ORM

## 🏗️ Project Structure

```
├── frontend/                   # React TypeScript frontend
│   ├── src/
│   │   ├── types/
│   │   │   └── note.ts         # TypeScript interfaces
│   │   ├── services/
│   │   │   └── noteService.ts  # API service layer
│   │   ├── components/
│   │   │   └── notes/          # Note components
│   │   └── pages/
│   │       └── Index.tsx       # Main app page
│   ├── package.json
│   ├── vite.config.ts
│   └── ...
├── backend/                    # FastAPI Python backend
│   ├── api/
│   │   └── routes.py          # API endpoints
│   ├── main.py                # FastAPI application
│   ├── models.py              # SQLAlchemy models
│   ├── schemas.py             # Pydantic schemas
│   ├── crud.py                # Database operations
│   ├── database.py            # Database configuration
│   ├── requirements.txt       # Python dependencies
│   └── README.md              # Backend documentation
└── README.md                  # This file
```

## 🚀 Quick Start

### Prerequisites
- Python 3.11+ (tested with 3.13)
- Node.js 18+
- npm or yarn

### Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd backend
   ```

2. **Create virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Start the server**:
   ```bash
   python main.py
   ```

   The API will be available at `http://localhost:8000`
   - API docs: `http://localhost:8000/docs`
   - Health check: `http://localhost:8000/health`

### Frontend Setup

1. **Navigate to frontend directory**:
   ```bash
   cd frontend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Start development server**:
   ```bash
   npm run dev
   ```

   The frontend will be available at `http://localhost:5173`

## 🔌 API Endpoints

The backend provides a complete REST API:

- `GET /api/notes` - Get all notes
- `POST /api/notes` - Create a new note
- `GET /api/notes/{id}` - Get a specific note
- `PUT /api/notes/{id}` - Update a note
- `DELETE /api/notes/{id}` - Delete a note
- `GET /health` - Health check
- `GET /docs` - Interactive API documentation

## 🎨 Design & Features

- **Catppuccin Mocha** color palette for beautiful dark theme
- **Google Keep-inspired** layout and interaction patterns
- **Responsive grid** that adapts to different screen sizes
- **Real-time updates** with proper API integration
- **Error handling** and loading states
- **Type safety** with TypeScript throughout

## 📝 Usage

1. **Create Note**: Click the "New Note" button
2. **Edit Note**: Click on any note card
3. **Delete Note**: Hover over a note and click the trash icon
4. **Search**: Use the search bar to find notes by title or content
5. **Colors**: Choose from 8 beautiful Catppuccin colors when editing

## 🛠️ Development

### Backend Development
- The backend uses FastAPI with automatic API documentation
- SQLite database for simplicity (easily changeable to PostgreSQL/MySQL)
- Full CORS support for frontend development
- Comprehensive error handling and validation

### Frontend Development
- Built with Vite for fast development
- Uses TanStack Query for efficient data fetching
- Responsive design with Tailwind CSS
- Component-based architecture with TypeScript

### Testing
Run the backend test suite:
```bash
cd backend
python test_api.py
```

## 🚀 Deployment

### Backend Deployment
The backend is ready for deployment to:
- AWS EC2
- Heroku
- DigitalOcean
- Any Python hosting service

### Frontend Deployment
The frontend can be deployed to:
- Vercel
- Netlify
- AWS S3 + CloudFront
- Any static hosting service

Update the API base URL in `frontend/src/services/noteService.ts` for production.

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the backend directory:
```env
DATABASE_URL=sqlite:///./notes.db
SECRET_KEY=your-secret-key
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
```

### CORS Configuration
The backend is configured to accept requests from common development ports. Update `main.py` for production domains.

---

This is a complete, production-ready full-stack application with a modern React frontend and robust FastAPI backend!

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

## 🚀 Quick Start Options

### 📱 Deploy to AWS EC2 (Recommended)

**🎯 SIMPLE: Want just the commands?** → **[`COMMANDS-TO-RUN.md`](./COMMANDS-TO-RUN.md)**

**📚 DETAILED: Want step-by-step guides?** → **[`0-OVERVIEW.md`](./0-OVERVIEW.md)**

### 💻 Local Development

For local development:

1. **Backend Setup**:
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   pip install -r requirements.txt
   python main.py
   ```
   Backend runs at `http://localhost:8000`

2. **Frontend Setup**:
   ```bash
   cd frontend
   npm install
   npm run dev
   ```
   Frontend runs at `http://localhost:5173`

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

### 🎯 AWS EC2 Deployment (Production Ready)

**Complete step-by-step guides available:**

| Step | Guide | Description |
|------|-------|-------------|
| **0** | [`0-OVERVIEW.md`](./0-OVERVIEW.md) | Deployment overview & quick start |
| **1** | [`1-EC2-SETUP.md`](./1-EC2-SETUP.md) | Launch EC2 instance |
| **2** | [`2-SERVER-SETUP.md`](./2-SERVER-SETUP.md) | Install software |
| **3** | [`3-CODE-DEPLOYMENT.md`](./3-CODE-DEPLOYMENT.md) | Deploy code |
| **4** | [`4-APPLICATION-STARTUP.md`](./4-APPLICATION-STARTUP.md) | Start services |
| **5** | [`5-TESTING-VERIFICATION.md`](./5-TESTING-VERIFICATION.md) | Test & verify |

**Total time: ~1 hour** ⏱️

### 🌐 Alternative Deployments
- **Vercel** (frontend) + **Railway** (backend)  
- **Netlify** (frontend) + **Heroku** (backend)
- **AWS Amplify** (full-stack)

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

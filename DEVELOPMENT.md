# Development Guide

Quick guide to get the full-stack Notes application running locally.

## 🚀 Quick Start (All-in-one)

If you have both Python and Node.js installed:

```bash
# Install all dependencies
npm run install:all

# Start both frontend and backend
npm run dev
```

This will start:
- Backend API at `http://localhost:8000`
- Frontend app at `http://localhost:5173`

## 🔧 Manual Setup

### Backend Setup

1. Navigate to backend:
   ```bash
   cd backend
   ```

2. Create virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   # or
   venv\Scripts\activate     # Windows
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Start the server:
   ```bash
   python main.py
   ```

### Frontend Setup

1. Navigate to frontend:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start development server:
   ```bash
   npm run dev
   ```

## 📋 Available Scripts

From the root directory:

- `npm run dev` - Start both frontend and backend
- `npm run dev:frontend` - Start only frontend
- `npm run dev:backend` - Start only backend
- `npm run install:all` - Install all dependencies
- `npm run test:backend` - Run backend tests
- `npm run build:frontend` - Build frontend for production

## 🔍 Verification

1. **Backend Health Check**: `http://localhost:8000/health`
2. **API Documentation**: `http://localhost:8000/docs`
3. **Frontend App**: `http://localhost:5173`

## 🛠️ Development Tips

- **Hot Reload**: Both frontend (Vite) and backend (uvicorn) support hot reload
- **API Changes**: The backend auto-generates OpenAPI docs at `/docs`
- **Database**: SQLite database is created automatically in `backend/notes.db`
- **CORS**: Already configured for local development

## 🐛 Troubleshooting

### Backend Issues
- Check Python version: `python --version` (3.11+ required)
- Verify virtual environment is activated
- Check port 8000 isn't in use: `lsof -i :8000`

### Frontend Issues
- Check Node.js version: `node --version` (18+ required)
- Clear cache: `rm -rf node_modules && npm install`
- Check port 5173 isn't in use

### Connection Issues
- Ensure backend is running before starting frontend
- Check CORS settings in `backend/main.py`
- Verify API base URL in `frontend/src/services/noteService.ts`

## 📚 Tech Stack

**Frontend:**
- React 18 + TypeScript
- Vite (build tool)
- TanStack Query (data fetching)
- Tailwind CSS (styling)
- Shadcn/ui (components)

**Backend:**
- FastAPI (Python web framework)
- SQLAlchemy (ORM)
- Pydantic (data validation)
- SQLite (database)
- Uvicorn (ASGI server)

That's it! You should now have a fully functional full-stack application running locally.
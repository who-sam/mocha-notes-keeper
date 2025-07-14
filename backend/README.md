# Notes API Backend

A FastAPI backend for the Notes application with full CRUD operations.

## Features

- ✅ **Full CRUD Operations**: Create, Read, Update, Delete notes
- ✅ **FastAPI**: Modern, fast Python web framework
- ✅ **SQLAlchemy ORM**: Database abstraction layer
- ✅ **SQLite Database**: Simple setup (easily changeable to PostgreSQL)
- ✅ **Pydantic Validation**: Request/response validation
- ✅ **CORS Support**: Configured for React frontend
- ✅ **Auto Documentation**: Swagger UI at `/docs`
- ✅ **Type Hints**: Full Python type annotations

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/api/notes` | Get all notes |
| POST   | `/api/notes` | Create a new note |
| GET    | `/api/notes/{id}` | Get a specific note |
| PUT    | `/api/notes/{id}` | Update a note |
| DELETE | `/api/notes/{id}` | Delete a note |
| GET    | `/` | Health check |
| GET    | `/docs` | API documentation |

## Setup Instructions

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Configure Environment (Optional)

```bash
cp .env.example .env
# Edit .env with your preferred settings
```

### 3. Run the Server

```bash
# Development mode with auto-reload
python main.py

# Or using uvicorn directly
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 4. Access the API

- **API Base URL**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

## Database

The application uses SQLite by default for simplicity. The database file (`notes.db`) will be created automatically when you first run the server.

### Changing to PostgreSQL

1. Install PostgreSQL dependencies:
```bash
pip install psycopg2-binary
```

2. Update the `DATABASE_URL` in `.env`:
```
DATABASE_URL=postgresql://username:password@localhost/notes_db
```

## Note Data Model

```json
{
  "id": "string",
  "title": "string",
  "content": "string", 
  "color": "string (optional hex color)",
  "created_at": "string (ISO timestamp)",
  "updated_at": "string (ISO timestamp)"
}
```

## API Response Format

All endpoints return responses in this format:

```json
{
  "success": boolean,
  "data": any | null,
  "error": string | null,
  "message": string | null
}
```

## Development

### Project Structure

```
backend/
├── main.py           # FastAPI application entry point
├── database.py       # Database configuration
├── models.py         # SQLAlchemy models
├── schemas.py        # Pydantic schemas
├── crud.py          # Database operations
├── api/
│   ├── __init__.py
│   └── routes.py    # API endpoints
├── requirements.txt  # Python dependencies
└── README.md
```

### Adding New Features

1. **New Models**: Add to `models.py`
2. **New Schemas**: Add to `schemas.py` 
3. **New CRUD Operations**: Add to `crud.py`
4. **New Endpoints**: Add to `api/routes.py`

## Production Deployment

### Using Docker (Recommended)

Create a `Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Using Gunicorn

```bash
pip install gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_URL` | `sqlite:///./notes.db` | Database connection string |
| `API_HOST` | `0.0.0.0` | API host |
| `API_PORT` | `8000` | API port |
| `DEBUG` | `True` | Debug mode |
| `CORS_ORIGINS` | localhost variants | Allowed CORS origins |

## Troubleshooting

### Common Issues

1. **Import Errors**: Make sure you're in the `backend` directory when running
2. **Database Errors**: Check that SQLite file permissions are correct
3. **CORS Errors**: Verify your frontend URL is in the CORS origins list
4. **Port Already in Use**: Change the port in `main.py` or stop the conflicting process

### Logs

The API logs all requests and errors. Check the console output for debugging information.

## License

This project is open source and available under the MIT License.
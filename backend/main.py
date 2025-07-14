from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from database import engine, Base
from api.routes import router

# Create database tables
def create_tables():
    Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Create database tables
    create_tables()
    yield
    # Shutdown: Add any cleanup here if needed

# Create FastAPI application
app = FastAPI(
    title="Notes API",
    description="A REST API for managing notes with full CRUD operations",
    version="1.0.0",
    lifespan=lifespan
)

# CORS configuration for React frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",  # React dev server
        "http://localhost:5173",  # Vite dev server  
        "http://localhost:8080",  # Alternative dev port
        "https://your-frontend-domain.com"  # Production frontend domain
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Include API routes
app.include_router(router)

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "message": "Notes API is running!", 
        "version": "1.0.0",
        "docs": "/docs"
    }

@app.get("/health")
async def health_check():
    """Health check for monitoring"""
    return {"status": "healthy", "message": "API is operational"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app", 
        host="0.0.0.0", 
        port=8000, 
        reload=True,
        log_level="info"
    )
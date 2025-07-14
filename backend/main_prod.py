from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
from database import engine, Base, test_connection
from api.routes import router
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Create database tables
def create_tables():
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Database tables created successfully")
    except Exception as e:
        print(f"❌ Failed to create database tables: {e}")
        raise

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Test connection and create database tables
    print("🚀 Starting Notes API...")
    
    if not test_connection():
        raise HTTPException(status_code=500, detail="Database connection failed")
    
    create_tables()
    print("✅ Application startup completed")
    yield
    # Shutdown: Add any cleanup here if needed
    print("🛑 Application shutdown")

# Create FastAPI application
app = FastAPI(
    title="Notes API",
    description="A REST API for managing notes with full CRUD operations",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/api/docs" if os.getenv("ENVIRONMENT") == "production" else "/docs",
    redoc_url="/api/redoc" if os.getenv("ENVIRONMENT") == "production" else "/redoc"
)

# CORS configuration
allowed_origins = os.getenv("CORS_ORIGINS", "").split(",")
allowed_origins = [origin.strip() for origin in allowed_origins if origin.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins or ["*"],  # Allow all if none specified
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Include API routes with prefix
app.include_router(router, prefix="/api")

# Serve static files (for frontend)
if os.path.exists("../frontend/dist"):
    app.mount("/", StaticFiles(directory="../frontend/dist", html=True), name="static")

@app.get("/api")
async def root():
    """API health check endpoint"""
    return {
        "message": "Notes API is running!", 
        "version": "1.0.0",
        "environment": os.getenv("ENVIRONMENT", "development"),
        "docs": "/api/docs"
    }

@app.get("/api/health")
async def health_check():
    """Health check for monitoring"""
    db_status = "healthy" if test_connection() else "unhealthy"
    return {
        "status": "healthy" if db_status == "healthy" else "unhealthy",
        "database": db_status,
        "message": "API is operational"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main_prod:app", 
        host=os.getenv("HOST", "0.0.0.0"), 
        port=int(os.getenv("PORT", 8000)), 
        reload=False,
        log_level="info"
    )
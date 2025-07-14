import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Check if running in production environment
if os.getenv("ENVIRONMENT") == "production":
    # Import production database configuration
    from database_prod import engine, Base, SessionLocal, get_db, test_connection
else:
    # Use development database configuration
    from sqlalchemy import create_engine
    from sqlalchemy.ext.declarative import declarative_base
    from sqlalchemy.orm import sessionmaker

    # Database URL - using SQLite for development
    SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./notes.db")

    engine = create_engine(
        SQLALCHEMY_DATABASE_URL, 
        connect_args={"check_same_thread": False} if "sqlite" in SQLALCHEMY_DATABASE_URL else {}
    )

    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

    Base = declarative_base()

    # Dependency to get database session
    def get_db():
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()
            
    # Test connection function for development (SQLite doesn't need testing)
    def test_connection():
        return True
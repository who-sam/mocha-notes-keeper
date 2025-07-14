from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Production MariaDB configuration
DB_USER = os.getenv("DB_USER", "notes_user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "SecurePassword123!")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_NAME = os.getenv("DB_NAME", "notes_db")

# MariaDB connection URL
SQLALCHEMY_DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Create engine with MariaDB specific settings
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    pool_pre_ping=True,  # Verify connections before use
    pool_recycle=3600,   # Recycle connections every hour
    pool_size=10,        # Connection pool size
    max_overflow=20,     # Max connections beyond pool_size
    echo=False           # Set to True for SQL debugging
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

# Test database connection
def test_connection():
    try:
        with engine.connect() as connection:
            result = connection.execute("SELECT 1")
            return True
    except Exception as e:
        print(f"Database connection failed: {e}")
        return False
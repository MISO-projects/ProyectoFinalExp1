import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

DATABASE_URL = os.getenv(
    "DATABASE_URL", "postgresql://root:orders-pass@pg_db:5432/orders-db"
)
TEST_DATABASE_URL = "sqlite:///./test.db"

if os.getenv("TESTING"):
    SQLALCHEMY_DATABASE_URL = TEST_DATABASE_URL
else:
    SQLALCHEMY_DATABASE_URL = DATABASE_URL

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args=(
        {"check_same_thread": False} if "sqlite" in SQLALCHEMY_DATABASE_URL else {}
    ),
    pool_size=20,
    max_overflow=30,
    pool_timeout=60,
    pool_recycle=1800
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

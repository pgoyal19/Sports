from typing import Generator, Optional

# Minimal DB stub to satisfy imports; replace with real DB later
class DummyDBSession:
    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        pass

def get_db() -> Generator[DummyDBSession, None, None]:
    db: Optional[DummyDBSession] = DummyDBSession()
    try:
        yield db
    finally:
        pass



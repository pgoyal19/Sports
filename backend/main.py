from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Support running from project root (absolute imports) and from backend/ (relative imports)
try:
    from backend.routes import auth, video_upload, results
except Exception:
    from routes import auth, video_upload, results

app = FastAPI(title="Sports Talent Assessment API")

# Enable CORS for local dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routes
app.include_router(auth.router)
app.include_router(video_upload.router)
app.include_router(results.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to Sports Talent Assessment API"}

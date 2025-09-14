from fastapi import APIRouter, UploadFile, File

# Support absolute (run from project root) and relative (run from backend/) imports
try:
    from backend.services import inference
except Exception:
    from services import inference
from backend.routes.results import LATEST_RESULT

router = APIRouter()

@router.post("/upload_video/")
async def upload_video(file: UploadFile = File(...)):
    contents = await file.read()
    result = inference.process_video(contents)
    response = {
        "score": result.get("score", 0.0),
        "cheat_detected": result.get("cheat_detected", 0),
        "analysis": result.get("analysis", {}),
        "video_info": result.get("video_info", {})
    }
    try:
        # Assign atomically to module variable, handling both import styles
        try:
            from backend.routes import results as results_module  # type: ignore
        except Exception:
            from routes import results as results_module  # type: ignore
        results_module.LATEST_RESULT = response  # type: ignore[arg-type]
    except Exception:
        pass
    # Return flat JSON to match mobile client expectations
    return response

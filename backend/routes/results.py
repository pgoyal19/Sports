from fastapi import APIRouter
from typing import Dict, Any, List

# Simple in-memory state for demo purposes
LATEST_RESULT: Dict[str, Any] | None = None
LEADERBOARD: List[Dict[str, Any]] = [
    {"rank": 1, "name": "Alex Runner", "score": 92, "color": "#10B981"},
    {"rank": 2, "name": "Jamie Jumper", "score": 88, "color": "#2563EB"},
    {"rank": 3, "name": "Sam Sprinter", "score": 85, "color": "#F59E0B"},
]

router = APIRouter(prefix="/results", tags=["results"])

@router.get("/athletes")
def list_athletes():
    return {
        "athletes": [
            {"id": 1, "name": "Alex Runner", "sport": "Sprinting"},
            {"id": 2, "name": "Jamie Jumper", "sport": "Long Jump"},
        ]
    }


@router.get("/latest")
def latest_result():
    # Return last uploaded inference result
    return LATEST_RESULT or {"score": 0.0, "cheat_detected": 0}


@router.get("/leaderboard")
def get_leaderboard():
    return {"items": LEADERBOARD}



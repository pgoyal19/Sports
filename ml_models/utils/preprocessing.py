import numpy as np

_USE_MEDIAPIPE = False
try:
    import mediapipe as mp  # type: ignore

    _mp_pose = mp.solutions.pose
    _pose = _mp_pose.Pose(static_image_mode=False,
                          model_complexity=1,
                          enable_segmentation=False,
                          min_detection_confidence=0.5,
                          min_tracking_confidence=0.5)
    _USE_MEDIAPIPE = True
except Exception:
    _USE_MEDIAPIPE = False


def extract_pose_landmarks(frame) -> np.ndarray:
    """
    Returns array shape (33, 3) for x,y,z pose landmarks normalized to [0,1] coordinates where possible.
    Falls back to zeros if MediaPipe is unavailable or detection fails.
    """
    if not _USE_MEDIAPIPE or frame is None:
        return np.zeros((33, 3), dtype=float)

    try:
        img_rgb = frame[:, :, ::-1]
        results = _pose.process(img_rgb)
        if not results.pose_landmarks:
            return np.zeros((33, 3), dtype=float)

        lm = results.pose_landmarks.landmark
        out = np.zeros((33, 3), dtype=float)
        for i in range(min(33, len(lm))):
            out[i, 0] = lm[i].x
            out[i, 1] = lm[i].y
            out[i, 2] = lm[i].z
        return out
    except Exception:
        return np.zeros((33, 3), dtype=float)




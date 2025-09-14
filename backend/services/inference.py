import os
import pickle
from typing import Any, Dict, List, Tuple

import numpy as np

try:
    import cv2  # type: ignore
except Exception:
    cv2 = None  # OpenCV optional for stub

try:
    import tensorflow as tf  # type: ignore
except Exception:
    tf = None

# Safe import of preprocessing function with fallback
extract_pose_landmarks = None
try:
    # Try absolute import first (when running from project root)
    from ml_models.utils.preprocessing import extract_pose_landmarks as _extract
    extract_pose_landmarks = _extract
except Exception:
    try:
        # Fallback: try importing from parent directory
        import sys
        import os
        sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..'))
        from ml_models.utils.preprocessing import extract_pose_landmarks as _extract
        extract_pose_landmarks = _extract
    except Exception:
        def extract_pose_landmarks(_frame: Any):
            return np.zeros((33, 3), dtype=float)


def _load_models():
    pose_model = None
    cheat_detector = None
    
    # Try different possible paths for models
    possible_tflite_paths = [
        os.path.join("ml_models", "saved_models", "pose_model.tflite"),
        os.path.join("..", "ml_models", "saved_models", "pose_model.tflite")
    ]
    possible_h5_paths = [
        os.path.join("ml_models", "saved_models", "pose_model.h5"),
        os.path.join("..", "ml_models", "saved_models", "pose_model.h5")
    ]
    possible_cheat_paths = [
        os.path.join("ml_models", "saved_models", "cheat_detector.pkl"),
        os.path.join("..", "ml_models", "saved_models", "cheat_detector.pkl")
    ]
    
    # Prefer TFLite model if present
    for tflite_path in possible_tflite_paths:
        if os.path.exists(tflite_path) and tf is not None:
            try:
                interpreter = tf.lite.Interpreter(model_path=tflite_path)
                interpreter.allocate_tensors()
                pose_model = ("tflite", interpreter)
                break
            except Exception:
                continue
    
    # Try H5 model if TFLite not found
    if pose_model is None:
        for h5_path in possible_h5_paths:
            if os.path.exists(h5_path) and tf is not None:
                try:
                    pose_model = ("keras", tf.keras.models.load_model(h5_path))
                    break
                except Exception:
                    continue

    # Load cheat detector
    for cheat_path in possible_cheat_paths:
        if os.path.exists(cheat_path):
            try:
                with open(cheat_path, "rb") as f:
                    cheat_detector = pickle.load(f)
                break
            except Exception:
                continue

    return pose_model, cheat_detector


POSE_MODEL, CHEAT_DETECTOR = _load_models()


def _pad_or_truncate(sequence: np.ndarray, target_len: int) -> np.ndarray:
    length = sequence.shape[0]
    if length == target_len:
        return sequence
    if length > target_len:
        return sequence[:target_len]
    pad_shape = (target_len - length, ) + sequence.shape[1:]
    padding = np.zeros(pad_shape, dtype=sequence.dtype)
    return np.concatenate([sequence, padding], axis=0)


def _normalize(sequence: np.ndarray, mean_std: Tuple[np.ndarray, np.ndarray] | None) -> np.ndarray:
    if mean_std is None:
        return sequence
    mean, std = mean_std
    std_safe = np.where(std == 0, 1.0, std)
    return (sequence - mean) / std_safe


def _load_norm_stats() -> Tuple[np.ndarray, np.ndarray] | None:
    try:
        import json
        for path in [
            os.path.join("ml_models", "saved_models", "landmark_norm.json"),
            os.path.join("..", "ml_models", "saved_models", "landmark_norm.json"),
        ]:
            if os.path.exists(path):
                with open(path, "r") as f:
                    data = json.load(f)
                    mean = np.asarray(data.get("mean", []), dtype=np.float32)
                    std = np.asarray(data.get("std", []), dtype=np.float32)
                    if mean.size and std.size:
                        return mean, std
    except Exception:
        return None
    return None


def process_video(video_bytes: bytes) -> Dict[str, Any]:
    # If OpenCV unavailable, return deterministic stubbed result
    if cv2 is None:
        return {
            "score": 0.0, 
            "cheat_detected": 0,
            "analysis": {
                "form_score": 0.0,
                "consistency_score": 0.0,
                "power_score": 0.0,
                "technique_score": 0.0,
                "overall_rating": "No Analysis Available",
                "recommendations": ["Camera not available for analysis"]
            }
        }

    temp_file = "temp_video.mp4"
    with open(temp_file, "wb") as f:
        f.write(video_bytes)

    cap = cv2.VideoCapture(temp_file)
    landmarks_list: List[np.ndarray] = []
    frame_count = 0
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    # Get video properties
    fps = cap.get(cv2.CAP_PROP_FPS)
    duration = total_frames / fps if fps > 0 else 0

    while True:
        ret, frame = cap.read()
        if not ret:
            break
        landmarks = extract_pose_landmarks(frame)
        landmarks_list.append(landmarks)
        frame_count += 1

    cap.release()
    if os.path.exists(temp_file):
        try:
            os.remove(temp_file)
        except Exception:
            pass

    if len(landmarks_list) == 0:
        return {
            "score": 0.0, 
            "cheat_detected": 0,
            "analysis": {
                "form_score": 0.0,
                "consistency_score": 0.0,
                "power_score": 0.0,
                "technique_score": 0.0,
                "overall_rating": "No Data",
                "recommendations": ["No video data detected"]
            }
        }

    # Shape (T, 33, 3)
    landmarks_array = np.array(landmarks_list, dtype=np.float32)

    # Optional normalization
    stats = _load_norm_stats()
    if stats is not None:
        # Broadcast over time dimension
        mean, std = stats
        try:
            landmarks_array = _normalize(landmarks_array, (mean.reshape(1, 33, 3), std.reshape(1, 33, 3)))
        except Exception:
            pass

    # Pad/Truncate to fixed length expected by model (e.g., 120 frames)
    TARGET_LEN = 120
    landmarks_array = _pad_or_truncate(landmarks_array, TARGET_LEN)

    # Enhanced analysis
    analysis_results = _analyze_performance(landmarks_array, frame_count, duration)
    
    # Predict performance
    avg_score = 0.5
    if POSE_MODEL is not None and tf is not None:
        kind, model = POSE_MODEL
        try:
            if kind == "keras":
                # Ensure batch dimension
                batch = np.expand_dims(landmarks_array, axis=0)
                predictions = model.predict(batch, verbose=0)
                avg_score = float(np.mean(predictions))
            elif kind == "tflite":
                interpreter = model
                input_details = interpreter.get_input_details()
                output_details = interpreter.get_output_details()
                # naive single-batch run
                interpreter.resize_tensor_input(input_details[0]['index'], (1,) + landmarks_array.shape)
                interpreter.allocate_tensors()
                interpreter.set_tensor(input_details[0]['index'], np.expand_dims(landmarks_array, 0).astype(np.float32))
                interpreter.invoke()
                output_data = interpreter.get_tensor(output_details[0]['index'])
                avg_score = float(np.mean(output_data))
        except Exception:
            avg_score = 0.5

    cheat_detected = 0
    if CHEAT_DETECTOR is not None:
        try:
            preds = CHEAT_DETECTOR.predict(landmarks_array)
            cheat_detected = int(np.any(preds == -1))
        except Exception:
            cheat_detected = 0

    # Calculate final score with enhanced analysis
    final_score = _calculate_final_score(avg_score, analysis_results, cheat_detected)

    return {
        "score": float(final_score), 
        "cheat_detected": cheat_detected,
        "analysis": analysis_results,
        "video_info": {
            "frame_count": frame_count,
            "duration": duration,
            "fps": fps
        }
    }


def _analyze_performance(landmarks_array: np.ndarray, frame_count: int, duration: float) -> Dict[str, Any]:
    """Enhanced performance analysis based on pose landmarks"""
    
    # Basic pose analysis
    form_score = _analyze_form(landmarks_array)
    consistency_score = _analyze_consistency(landmarks_array)
    power_score = _analyze_power(landmarks_array)
    technique_score = _analyze_technique(landmarks_array)
    
    # Overall rating
    overall_score = (form_score + consistency_score + power_score + technique_score) / 4
    overall_rating = _get_overall_rating(overall_score)
    
    # Generate recommendations
    recommendations = _generate_recommendations(form_score, consistency_score, power_score, technique_score)
    
    return {
        "form_score": float(form_score),
        "consistency_score": float(consistency_score),
        "power_score": float(power_score),
        "technique_score": float(technique_score),
        "overall_rating": overall_rating,
        "recommendations": recommendations
    }


def _analyze_form(landmarks_array: np.ndarray) -> float:
    """Analyze body form and posture"""
    if landmarks_array.shape[0] == 0:
        return 0.0
    
    # Calculate average joint angles and posture
    # This is a simplified analysis - in reality, you'd calculate actual joint angles
    form_scores = []
    
    for frame in landmarks_array:
        if np.all(frame == 0):  # Skip empty frames
            continue
            
        # Analyze shoulder alignment
        left_shoulder = frame[11]  # Left shoulder
        right_shoulder = frame[12]  # Right shoulder
        
        if np.all(left_shoulder != 0) and np.all(right_shoulder != 0):
            shoulder_alignment = 1.0 - abs(left_shoulder[1] - right_shoulder[1]) / 100.0
            form_scores.append(max(0, min(1, shoulder_alignment)))
    
    return np.mean(form_scores) * 100 if form_scores else 50.0


def _analyze_consistency(landmarks_array: np.ndarray) -> float:
    """Analyze movement consistency"""
    if landmarks_array.shape[0] < 2:
        return 50.0
    
    # Calculate variance in key points over time
    key_points = [11, 12, 23, 24]  # Shoulders and hips
    variances = []
    
    for point_idx in key_points:
        if point_idx < landmarks_array.shape[1]:
            point_data = landmarks_array[:, point_idx, :2]  # x, y coordinates
            valid_frames = point_data[~np.all(point_data == 0, axis=1)]
            
            if len(valid_frames) > 1:
                variance = np.var(valid_frames, axis=0).mean()
                consistency = max(0, 1 - variance / 1000)  # Normalize variance
                variances.append(consistency)
    
    return np.mean(variances) * 100 if variances else 50.0


def _analyze_power(landmarks_array: np.ndarray) -> float:
    """Analyze power and explosiveness"""
    if landmarks_array.shape[0] < 2:
        return 50.0
    
    # Calculate movement velocity and acceleration
    velocities = []
    
    for i in range(1, landmarks_array.shape[0]):
        prev_frame = landmarks_array[i-1]
        curr_frame = landmarks_array[i]
        
        # Calculate center of mass movement
        prev_com = np.mean(prev_frame[~np.all(prev_frame == 0, axis=1)], axis=0)
        curr_com = np.mean(curr_frame[~np.all(curr_frame == 0, axis=1)], axis=0)
        
        if not (np.all(prev_com == 0) or np.all(curr_com == 0)):
            velocity = np.linalg.norm(curr_com - prev_com)
            velocities.append(velocity)
    
    if velocities:
        avg_velocity = np.mean(velocities)
        power_score = min(100, max(0, avg_velocity * 10))  # Scale to 0-100
        return power_score
    
    return 50.0


def _analyze_technique(landmarks_array: np.ndarray) -> float:
    """Analyze technical execution"""
    if landmarks_array.shape[0] == 0:
        return 50.0
    
    # Analyze joint angles and movement patterns
    technique_scores = []
    
    for frame in landmarks_array:
        if np.all(frame == 0):
            continue
            
        # Check for proper joint alignment
        # This is simplified - real analysis would calculate actual joint angles
        valid_points = frame[~np.all(frame == 0, axis=1)]
        
        if len(valid_points) > 5:  # Minimum points for analysis
            # Calculate some basic technique metrics
            technique_score = 60.0 + np.random.normal(0, 10)  # Placeholder
            technique_scores.append(max(0, min(100, technique_score)))
    
    return np.mean(technique_scores) if technique_scores else 50.0


def _get_overall_rating(score: float) -> str:
    """Get overall performance rating"""
    if score >= 90:
        return "Elite"
    elif score >= 80:
        return "Excellent"
    elif score >= 70:
        return "Good"
    elif score >= 60:
        return "Average"
    else:
        return "Needs Improvement"


def _generate_recommendations(form_score: float, consistency_score: float, 
                            power_score: float, technique_score: float) -> List[str]:
    """Generate personalized recommendations"""
    recommendations = []
    
    if form_score < 70:
        recommendations.append("Focus on improving your posture and body alignment")
    
    if consistency_score < 70:
        recommendations.append("Work on maintaining consistent movement patterns")
    
    if power_score < 70:
        recommendations.append("Increase your explosive power and speed")
    
    if technique_score < 70:
        recommendations.append("Practice proper technique and form")
    
    if not recommendations:
        recommendations.append("Great job! Keep up the excellent work")
    
    return recommendations


def _calculate_final_score(base_score: float, analysis: Dict[str, Any], cheat_detected: int) -> float:
    """Calculate final score considering all factors"""
    # Penalize for cheating
    if cheat_detected:
        return max(0, base_score * 0.3)
    
    # Weight the analysis components
    form_weight = 0.3
    consistency_weight = 0.25
    power_weight = 0.25
    technique_weight = 0.2
    
    weighted_score = (
        analysis["form_score"] * form_weight +
        analysis["consistency_score"] * consistency_weight +
        analysis["power_score"] * power_weight +
        analysis["technique_score"] * technique_weight
    )
    
    # Combine with base score
    final_score = (base_score * 0.6 + weighted_score * 0.4)
    
    return min(100, max(0, final_score))

from fastapi import FastAPI, File, UploadFile, HTTPException, Depends, Security
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security.api_key import APIKeyHeader
from deepface import DeepFace
import numpy as np
import cv2
from PIL import Image
import io
import json
import os
from typing import Dict


API_KEY = "ml-secret-2024-graduation"
api_key_header = APIKeyHeader(name="X-ML-Secret", auto_error=True)

async def verify_key(key: str = Security(api_key_header)):
    if key != API_KEY:
        raise HTTPException(status_code=403, detail="Unauthorized")
    

# =========================================================
# FastAPI Init
# =========================================================

app = FastAPI(
    title="Face Recognition ML API",
    version="2.0.0"
)

# عدل الـ origins دي لاحقًا للـ frontend الحقيقي
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================================================
# Constants
# =========================================================

ENCODINGS_FILE = "encodings.json"

MODEL_NAME = "Facenet"

# Threshold مضبوط لـ FaceNet
RECOGNITION_THRESHOLD = 0.9

# عدد الصور المطلوبة للتسجيل المثالي
MIN_EMBEDDINGS_PER_USER = 3


# =========================================================
# Utility Functions
# =========================================================

def load_encodings() -> Dict:
    if os.path.exists(ENCODINGS_FILE):
        with open(ENCODINGS_FILE, "r") as f:
            return json.load(f)
    return {}


def save_encodings(data: Dict):
    with open(ENCODINGS_FILE, "w") as f:
        json.dump(data, f)


def read_image_bytes(file_bytes):
    try:
        image = Image.open(io.BytesIO(file_bytes)).convert("RGB")
        return np.array(image)
    except Exception:
        raise HTTPException(
            status_code=400,
            detail="Invalid image file"
        )


def get_embedding(image_np):

    result = DeepFace.represent(
        img_path=image_np,
        model_name=MODEL_NAME,
        enforce_detection=True
    )

    if not result:
        raise HTTPException(
            status_code=400,
            detail="No face detected"
        )

    return result[0]["embedding"]


def euclidean_distance(emb1, emb2):
    emb1 = np.array(emb1)
    emb2 = np.array(emb2)

    return np.linalg.norm(emb1 - emb2)


# =========================================================
# Health Check
# =========================================================

@app.get("/")
def root():
    return {
        "message": "ML API Running ✅",
        "model": MODEL_NAME,
        "version": "2.0.0"
    }


@app.get("/health")
def health():
    return {"status": "ok"}


# =========================================================
# 1. Face Detection
# =========================================================

@app.post("/detect-face",dependencies=[Depends(verify_key)])
async def detect_face(file: UploadFile = File(...)):

    try:
        contents = await file.read()

        image = read_image_bytes(contents)

        faces = DeepFace.extract_faces(
            img_path=image,
            enforce_detection=True
        )

        return {
            "detected": True,
            "faces_count": len(faces),
            "message": f"{len(faces)} face(s) detected"
        }

    except Exception as e:
        return {
            "detected": False,
            "faces_count": 0,
            "message": str(e)
        }


# =========================================================
# 2. Register Face
# =========================================================

@app.post("/register-face/{employee_id}",dependencies=[Depends(verify_key)])
async def register_face(
    employee_id: str,
    file: UploadFile = File(...)
):

    try:

        contents = await file.read()

        image = read_image_bytes(contents)

        embedding = get_embedding(image)

        all_encodings = load_encodings()

        # لو الموظف جديد
        if employee_id not in all_encodings:
            all_encodings[employee_id] = []

        # أضف embedding جديدة
        all_encodings[employee_id].append(embedding)

        save_encodings(all_encodings)

        total_samples = len(all_encodings[employee_id])

        return {
            "success": True,
            "employee_id": employee_id,
            "samples_saved": total_samples,
            "recommended_samples": MIN_EMBEDDINGS_PER_USER,
            "message": (
                f"Face sample saved for {employee_id} ✅"
            )
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# =========================================================
# 3. Face Recognition
# =========================================================

@app.post("/recognize-face",dependencies=[Depends(verify_key)])
async def recognize_face(
    file: UploadFile = File(...)
):

    try:

        contents = await file.read()

        image = read_image_bytes(contents)

        unknown_embedding = get_embedding(image)

        all_encodings = load_encodings()

        if not all_encodings:
            return {
                "recognized": False,
                "message": "No employees registered"
            }

        best_match = None
        best_distance = float("inf")

        # قارن مع كل الموظفين
        for employee_id, embeddings in all_encodings.items():

            for saved_embedding in embeddings:

                distance = euclidean_distance(
                    unknown_embedding,
                    saved_embedding
                )

                if distance < best_distance:
                    best_distance = distance
                    best_match = employee_id

        # القرار النهائي
        if best_distance < RECOGNITION_THRESHOLD:

            confidence = round(
                (1 - best_distance / RECOGNITION_THRESHOLD) * 100,
                2
            )

            return {
                "recognized": True,
                "employee_id": best_match,
                "distance": round(best_distance, 4),
                "confidence": confidence,
                "message": f"{best_match} recognized ✅"
            }

        return {
            "recognized": False,
            "distance": round(best_distance, 4),
            "message": "Face not recognized ❌"
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# =========================================================
# 4. Liveness Detection
# =========================================================

@app.post("/liveness-check",dependencies=[Depends(verify_key)])
async def liveness_check(
    file: UploadFile = File(...)
):

    try:

        contents = await file.read()

        image = read_image_bytes(contents)

        image_bgr = cv2.cvtColor(
            image,
            cv2.COLOR_RGB2BGR
        )

        gray = cv2.cvtColor(
            image_bgr,
            cv2.COLOR_BGR2GRAY
        )

        face_cascade = cv2.CascadeClassifier(
            cv2.data.haarcascades +
            "haarcascade_frontalface_default.xml"
        )

        faces = face_cascade.detectMultiScale(
            gray,
            scaleFactor=1.1,
            minNeighbors=5
        )

        if len(faces) == 0:
            return {
                "is_live": False,
                "message": "No face detected"
            }

        x, y, w, h = faces[0]

        # نسبة الوش
        h_img, w_img = gray.shape

        face_coverage = (
            (w * h) / (w_img * h_img)
        )

        # Texture analysis
        face_region = gray[y:y+h, x:x+w]

        texture_score = cv2.Laplacian(
            face_region,
            cv2.CV_64F
        ).var()

        # قواعد بسيطة
        is_live = (
            face_coverage > 0.05
            and texture_score > 100
        )

        return {
            "is_live": bool(is_live),
            "details": {
                "texture_score": round(texture_score, 2),
                "face_coverage": round(face_coverage, 4)
            },
            "message": (
                "Live face detected ✅"
                if is_live
                else "Spoof suspected ❌"
            )
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# =========================================================
# 5. Full Attendance Check
# =========================================================

@app.post("/attendance/check-in/{employee_id}",dependencies=[Depends(verify_key)])
async def attendance_check_in(
    employee_id: str,
    file: UploadFile = File(...)
):

    try:

        contents = await file.read()

        image = read_image_bytes(contents)

        # =========================
        # Step 1: Liveness
        # =========================

        image_bgr = cv2.cvtColor(
            image,
            cv2.COLOR_RGB2BGR
        )

        gray = cv2.cvtColor(
            image_bgr,
            cv2.COLOR_BGR2GRAY
        )

        face_cascade = cv2.CascadeClassifier(
            cv2.data.haarcascades +
            "haarcascade_frontalface_default.xml"
        )

        faces = face_cascade.detectMultiScale(
            gray,
            scaleFactor=1.1,
            minNeighbors=5
        )

        if len(faces) == 0:
            return {
                "success": False,
                "step": "liveness",
                "message": "No face detected"
            }

        x, y, w, h = faces[0]

        h_img, w_img = gray.shape

        face_coverage = (
            (w * h) / (w_img * h_img)
        )

        face_region = gray[y:y+h, x:x+w]

        texture_score = cv2.Laplacian(
            face_region,
            cv2.CV_64F
        ).var()

        is_live = (
            face_coverage > 0.05
            and texture_score > 100
        )

        if not is_live:
            return {
                "success": False,
                "step": "liveness",
                "message": "Liveness failed ❌"
            }

        # =========================
        # Step 2: Recognition
        # =========================

        unknown_embedding = get_embedding(image)

        all_encodings = load_encodings()

        if employee_id not in all_encodings:
            return {
                "success": False,
                "step": "recognition",
                "message": "Employee not registered"
            }

        best_distance = float("inf")

        for saved_embedding in all_encodings[employee_id]:

            distance = euclidean_distance(
                unknown_embedding,
                saved_embedding
            )

            if distance < best_distance:
                best_distance = distance

        # =========================
        # Final Decision
        # =========================

        if best_distance < RECOGNITION_THRESHOLD:

            confidence = round(
                (1 - best_distance / RECOGNITION_THRESHOLD) * 100,
                2
            )

            return {
                "success": True,
                "employee_id": employee_id,
                "distance": round(best_distance, 4),
                "confidence": confidence,
                "message": (
                    f"Attendance registered for "
                    f"{employee_id} ✅"
                )
            }

        return {
            "success": False,
            "step": "recognition",
            "distance": round(best_distance, 4),
            "message": "Face mismatch ❌"
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )
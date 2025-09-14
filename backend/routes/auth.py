from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
import random
import string
from datetime import datetime, timedelta
import jwt
from typing import Dict, Optional

router = APIRouter()

# In-memory storage for OTPs (in production, use Redis or database)
otp_storage: Dict[str, Dict] = {}

# JWT secret key (in production, use environment variable)
SECRET_KEY = "your-secret-key-here"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

class PhoneNumberRequest(BaseModel):
    phone_number: str

class OTPVerificationRequest(BaseModel):
    phone_number: str
    otp: str

def generate_otp() -> str:
    """Generate a 6-digit OTP"""
    return ''.join(random.choices(string.digits, k=6))

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """Create JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

@router.post("/send-otp")
async def send_otp(request: PhoneNumberRequest):
    """Send OTP to phone number"""
    phone_number = request.phone_number
    
    # Validate phone number (basic validation)
    if not phone_number.isdigit() or len(phone_number) != 10:
        raise HTTPException(
            status_code=400,
            detail="Invalid phone number. Please enter a 10-digit number."
        )
    
    # Generate OTP
    otp = generate_otp()
    
    # Store OTP with expiration time (5 minutes)
    otp_storage[phone_number] = {
        "otp": otp,
        "expires_at": datetime.utcnow() + timedelta(minutes=5),
        "attempts": 0
    }
    
    # In production, integrate with SMS service like Twilio, AWS SNS, etc.
    # For now, we'll just return the OTP in the response for testing
    print(f"OTP for {phone_number}: {otp}")
    
    return {
        "message": f"OTP sent to +91{phone_number}",
        "phone_number": phone_number,
        "otp": otp  # Remove this in production
    }

@router.post("/verify-otp")
async def verify_otp(request: OTPVerificationRequest):
    """Verify OTP and return access token"""
    phone_number = request.phone_number
    otp = request.otp
    
    # Check if OTP exists
    if phone_number not in otp_storage:
        raise HTTPException(
            status_code=400,
            detail="OTP not found. Please request a new OTP."
        )
    
    otp_data = otp_storage[phone_number]
    
    # Check if OTP has expired
    if datetime.utcnow() > otp_data["expires_at"]:
        del otp_storage[phone_number]
        raise HTTPException(
            status_code=400,
            detail="OTP has expired. Please request a new OTP."
        )
    
    # Check attempts limit
    if otp_data["attempts"] >= 3:
        del otp_storage[phone_number]
        raise HTTPException(
            status_code=400,
            detail="Too many failed attempts. Please request a new OTP."
        )
    
    # Verify OTP
    if otp_data["otp"] != otp:
        otp_data["attempts"] += 1
        raise HTTPException(
            status_code=400,
            detail=f"Invalid OTP. {3 - otp_data['attempts']} attempts remaining."
        )
    
    # OTP is valid, create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": phone_number}, expires_delta=access_token_expires
    )
    
    # Remove OTP from storage
    del otp_storage[phone_number]
    
    return {
        "message": "OTP verified successfully",
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60
    }

@router.post("/resend-otp")
async def resend_otp(request: PhoneNumberRequest):
    """Resend OTP to phone number"""
    phone_number = request.phone_number
    
    # Validate phone number
    if not phone_number.isdigit() or len(phone_number) != 10:
        raise HTTPException(
            status_code=400,
            detail="Invalid phone number. Please enter a 10-digit number."
        )
    
    # Generate new OTP
    otp = generate_otp()
    
    # Store new OTP
    otp_storage[phone_number] = {
        "otp": otp,
        "expires_at": datetime.utcnow() + timedelta(minutes=5),
        "attempts": 0
    }
    
    # In production, send SMS
    print(f"New OTP for {phone_number}: {otp}")
    
    return {
        "message": f"OTP resent to +91{phone_number}",
        "phone_number": phone_number,
        "otp": otp  # Remove this in production
    }

@router.get("/verify-token")
async def verify_token(token: str):
    """Verify JWT token"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        phone_number: str = payload.get("sub")
        if phone_number is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return {"valid": True, "phone_number": phone_number}
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid token")




class LoginRequest(BaseModel):
    email: str
    password: str

@router.post("/login")
async def login(request: LoginRequest):
    """Login with email and password (for demo purposes)"""
    # This is a simple demo login - in production, use proper authentication
    if request.email == "demo@gochamp.com" and request.password == "demo123":
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": request.email}, expires_delta=access_token_expires
        )
        return {
            "success": True,
            "message": "Login successful",
            "access_token": access_token,
            "token_type": "bearer",
            "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60
        }
    else:
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password"
        )
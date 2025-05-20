from fastapi import APIRouter

router = APIRouter()

@router.get("/")
async def get_settings():
    return {"message": "系统设置API"} 
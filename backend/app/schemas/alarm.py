from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional

class AlarmBase(BaseModel):
    time: datetime
    vibration: bool = True
    sound: str = "默认铃声"
    repeat_days: List[bool]
    description: Optional[str] = None
    user_id: int

class AlarmCreate(AlarmBase):
    pass

class AlarmUpdate(BaseModel):
    time: Optional[datetime] = None
    is_active: Optional[bool] = None
    vibration: Optional[bool] = None
    sound: Optional[str] = None
    repeat_days: Optional[List[bool]] = None
    description: Optional[str] = None

class AlarmResponse(AlarmBase):
    id: int
    is_active: bool

    class Config:
        from_attributes = True 
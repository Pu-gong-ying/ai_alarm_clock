from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models.alarm import Alarm
from ..schemas.alarm import AlarmCreate, AlarmUpdate, AlarmResponse

router = APIRouter()

@router.get("/", response_model=List[AlarmResponse])
def get_alarms(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    alarms = db.query(Alarm).offset(skip).limit(limit).all()
    return alarms

@router.post("/", response_model=AlarmResponse)
def create_alarm(alarm: AlarmCreate, db: Session = Depends(get_db)):
    db_alarm = Alarm(**alarm.dict())
    db.add(db_alarm)
    db.commit()
    db.refresh(db_alarm)
    return db_alarm

@router.get("/{alarm_id}", response_model=AlarmResponse)
def get_alarm(alarm_id: int, db: Session = Depends(get_db)):
    alarm = db.query(Alarm).filter(Alarm.id == alarm_id).first()
    if alarm is None:
        raise HTTPException(status_code=404, detail="闹钟不存在")
    return alarm

@router.put("/{alarm_id}", response_model=AlarmResponse)
def update_alarm(alarm_id: int, alarm: AlarmUpdate, db: Session = Depends(get_db)):
    db_alarm = db.query(Alarm).filter(Alarm.id == alarm_id).first()
    if db_alarm is None:
        raise HTTPException(status_code=404, detail="闹钟不存在")
    
    for key, value in alarm.dict(exclude_unset=True).items():
        setattr(db_alarm, key, value)
    
    db.commit()
    db.refresh(db_alarm)
    return db_alarm

@router.delete("/{alarm_id}")
def delete_alarm(alarm_id: int, db: Session = Depends(get_db)):
    alarm = db.query(Alarm).filter(Alarm.id == alarm_id).first()
    if alarm is None:
        raise HTTPException(status_code=404, detail="闹钟不存在")
    
    db.delete(alarm)
    db.commit()
    return {"message": "闹钟已删除"} 
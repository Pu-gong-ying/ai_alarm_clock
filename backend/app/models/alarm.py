from sqlalchemy import Column, Integer, DateTime, Boolean, String, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()

class Alarm(Base):
    __tablename__ = "alarms"

    id = Column(Integer, primary_key=True, index=True)
    time = Column(DateTime, nullable=False)
    is_active = Column(Boolean, default=True)
    vibration = Column(Boolean, default=True)
    sound = Column(String, default="默认铃声")
    repeat_days = Column(JSON)  # 存储为JSON数组 [true, false, true, ...]
    description = Column(String, nullable=True)
    user_id = Column(Integer, nullable=False)  # 关联用户ID
    
    # 关系
    histories = relationship("AlarmHistory", back_populates="alarm") 
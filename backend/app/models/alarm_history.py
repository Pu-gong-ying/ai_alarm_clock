"""
闹钟历史记录模型模块

定义闹钟触发历史记录的数据库模型，用于：
1. 记录闹钟触发时间
2. 记录用户响应时间
3. 记录闹钟状态变化
"""

from sqlalchemy import Column, Integer, DateTime, String, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from ..database import Base

class AlarmHistory(Base):
    """
    闹钟历史记录模型类
    
    属性：
    - id: 主键
    - alarm_id: 闹钟ID（外键）
    - triggered_at: 触发时间
    - responded_at: 响应时间
    - status: 状态（missed/snoozed/dismissed）
    - created_at: 创建时间
    """
    __tablename__ = "alarm_history"

    id = Column(Integer, primary_key=True, index=True)
    alarm_id = Column(Integer, ForeignKey("alarms.id"))
    triggered_at = Column(DateTime, nullable=False)
    responded_at = Column(DateTime)
    status = Column(String, nullable=False)  # missed/snoozed/dismissed
    created_at = Column(DateTime, default=datetime.utcnow)

    # 关系
    alarm = relationship("Alarm", back_populates="history") 
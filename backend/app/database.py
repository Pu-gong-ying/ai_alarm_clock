"""
数据库配置模块

此模块负责：
1. 配置SQLAlchemy数据库连接
2. 创建数据库会话
3. 提供数据库依赖注入
"""

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
from .models.alarm import Base as AlarmBase

# 数据库URL配置
# 使用环境变量或默认值
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./ai_alarm.db")

# 创建SQLAlchemy引擎
# echo=True 启用SQL语句日志
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False},  # 仅用于SQLite
    echo=True
)

# 创建会话工厂
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 创建基类
Base = declarative_base()

async def init_db():
    """
    初始化数据库
    
    负责：
    1. 创建所有表
    2. 执行必要的数据库迁移
    """
    # 导入所有模型以确保它们被注册
    from .models import alarm, user, settings
    
    # 创建所有表
    Base.metadata.create_all(bind=engine)

def get_db():
    """
    获取数据库会话
    
    用于依赖注入，确保会话在使用后被正确关闭
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 初始化数据库
def init_db():
    AlarmBase.metadata.create_all(bind=engine) 
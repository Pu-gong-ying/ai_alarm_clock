"""
智能闹钟应用主模块

此模块负责：
1. 初始化FastAPI应用
2. 配置数据库连接
3. 注册路由
4. 启动闹钟服务
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .api import alarms, users, settings
from .database import init_db, SessionLocal
from .services.alarm_service import AlarmService
import logging

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="智能闹钟API",
    description="智能闹钟应用的后端API服务",
    version="1.0.0"
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 在生产环境中应该限制为特定域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
app.include_router(alarms.router, prefix="/api/v1/alarms", tags=["闹钟管理"])
app.include_router(users.router, prefix="/api/v1/users", tags=["用户管理"])
app.include_router(settings.router, prefix="/api/v1/settings", tags=["系统设置"])

# 创建闹钟服务实例
alarm_service = AlarmService()

@app.on_event("startup")
async def startup_event():
    """
    应用启动时执行的事件处理函数
    
    负责：
    1. 初始化数据库
    2. 启动闹钟服务
    """
    try:
        # 初始化数据库
        await init_db()
        logger.info("数据库初始化完成")
        
        # 启动闹钟服务
        await alarm_service.start()
        logger.info("闹钟服务启动完成")
    except Exception as e:
        logger.error(f"启动时发生错误: {str(e)}")
        raise

@app.on_event("shutdown")
async def shutdown_event():
    """
    应用关闭时执行的事件处理函数
    
    负责：
    1. 停止闹钟服务
    2. 清理资源
    """
    try:
        await alarm_service.stop()
        logger.info("闹钟服务已停止")
    except Exception as e:
        logger.error(f"关闭时发生错误: {str(e)}")
        raise

@app.get("/")
async def root():
    return {"message": "欢迎使用AI智能闹钟系统API"} 
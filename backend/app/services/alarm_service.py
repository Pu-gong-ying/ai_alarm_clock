from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from ..models.alarm import Alarm
import asyncio
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AlarmService:
    def __init__(self, db: Session):
        self.db = db
        self.active_alarms = set()

    def check_alarm_time(self, alarm: Alarm) -> bool:
        """检查闹钟是否应该触发"""
        now = datetime.now()
        alarm_time = alarm.time
        
        # 检查时间是否匹配
        if (now.hour == alarm_time.hour and 
            now.minute == alarm_time.minute and 
            now.second < 10):  # 给予10秒的触发窗口
            
            # 检查重复设置
            if alarm.repeat_days:
                weekday = now.weekday()  # 0-6 对应周一到周日
                if not alarm.repeat_days[weekday]:
                    return False
            
            return True
        return False

    async def check_alarms(self):
        """定期检查闹钟"""
        while True:
            try:
                alarms = self.db.query(Alarm).filter(Alarm.is_active == True).all()
                for alarm in alarms:
                    if self.check_alarm_time(alarm):
                        await self.trigger_alarm(alarm)
                
                # 每分钟检查一次
                await asyncio.sleep(60)
            except Exception as e:
                logger.error(f"检查闹钟时发生错误: {str(e)}")
                await asyncio.sleep(60)  # 发生错误时等待一分钟后重试

    async def trigger_alarm(self, alarm: Alarm):
        """触发闹钟"""
        try:
            logger.info(f"触发闹钟: ID={alarm.id}, 时间={alarm.time}")
            # 记录触发历史
            # TODO: 实现触发历史记录
            
        except Exception as e:
            logger.error(f"触发闹钟时发生错误: {str(e)}")

    def start(self):
        """启动闹钟服务"""
        asyncio.create_task(self.check_alarms()) 
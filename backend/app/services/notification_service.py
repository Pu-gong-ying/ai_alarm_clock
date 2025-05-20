import logging
from datetime import datetime
from typing import Optional
import platform
import subprocess
import os

logger = logging.getLogger(__name__)

class NotificationService:
    def __init__(self):
        self.system = platform.system()
    
    def send_notification(self, title: str, message: str, priority: str = "normal") -> bool:
        """
        发送系统通知
        :param title: 通知标题
        :param message: 通知内容
        :param priority: 优先级 (low, normal, high)
        :return: 是否发送成功
        """
        try:
            if self.system == "Windows":
                return self._send_windows_notification(title, message)
            elif self.system == "Darwin":  # macOS
                return self._send_macos_notification(title, message)
            elif self.system == "Linux":
                return self._send_linux_notification(title, message)
            else:
                logger.warning(f"不支持的操作系统: {self.system}")
                return False
        except Exception as e:
            logger.error(f"发送通知失败: {str(e)}")
            return False
    
    def _send_windows_notification(self, title: str, message: str) -> bool:
        """Windows系统通知"""
        try:
            from win10toast import ToastNotifier
            toaster = ToastNotifier()
            toaster.show_toast(title, message, duration=10, threaded=True)
            return True
        except ImportError:
            logger.error("未安装win10toast包")
            return False
    
    def _send_macos_notification(self, title: str, message: str) -> bool:
        """macOS系统通知"""
        try:
            os.system(f"""
                osascript -e 'display notification "{message}" with title "{title}"'
            """)
            return True
        except Exception as e:
            logger.error(f"macOS通知发送失败: {str(e)}")
            return False
    
    def _send_linux_notification(self, title: str, message: str) -> bool:
        """Linux系统通知"""
        try:
            subprocess.run(['notify-send', title, message])
            return True
        except Exception as e:
            logger.error(f"Linux通知发送失败: {str(e)}")
            return False 
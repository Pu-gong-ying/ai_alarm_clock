import logging
import os
from pathlib import Path
import platform
import subprocess
from typing import Optional

logger = logging.getLogger(__name__)

class SoundService:
    def __init__(self):
        self.system = platform.system()
        self.sounds_dir = Path("sounds")
        self.sounds_dir.mkdir(exist_ok=True)
        self._init_default_sounds()
    
    def _init_default_sounds(self):
        """初始化默认铃声"""
        default_sounds = {
            "默认铃声": "default.mp3",
            "轻柔铃声": "gentle.mp3",
            "活力铃声": "energetic.mp3"
        }
        
        # 确保所有默认铃声文件存在
        for sound_name, filename in default_sounds.items():
            sound_path = self.sounds_dir / filename
            if not sound_path.exists():
                logger.warning(f"默认铃声文件不存在: {filename}")
    
    def play_sound(self, sound_name: str, volume: int = 100) -> bool:
        """
        播放指定铃声
        :param sound_name: 铃声名称
        :param volume: 音量 (0-100)
        :return: 是否播放成功
        """
        try:
            sound_file = self.sounds_dir / f"{sound_name}.mp3"
            if not sound_file.exists():
                logger.error(f"铃声文件不存在: {sound_name}")
                return False
            
            if self.system == "Windows":
                return self._play_windows_sound(sound_file, volume)
            elif self.system == "Darwin":  # macOS
                return self._play_macos_sound(sound_file, volume)
            elif self.system == "Linux":
                return self._play_linux_sound(sound_file, volume)
            else:
                logger.warning(f"不支持的操作系统: {self.system}")
                return False
        except Exception as e:
            logger.error(f"播放声音失败: {str(e)}")
            return False
    
    def _play_windows_sound(self, sound_file: Path, volume: int) -> bool:
        """Windows系统播放声音"""
        try:
            from playsound import playsound
            playsound(str(sound_file))
            return True
        except ImportError:
            logger.error("未安装playsound包")
            return False
    
    def _play_macos_sound(self, sound_file: Path, volume: int) -> bool:
        """macOS系统播放声音"""
        try:
            os.system(f"afplay {sound_file}")
            return True
        except Exception as e:
            logger.error(f"macOS声音播放失败: {str(e)}")
            return False
    
    def _play_linux_sound(self, sound_file: Path, volume: int) -> bool:
        """Linux系统播放声音"""
        try:
            subprocess.run(['paplay', str(sound_file)])
            return True
        except Exception as e:
            logger.error(f"Linux声音播放失败: {str(e)}")
            return False
    
    def stop_sound(self) -> bool:
        """停止播放声音"""
        try:
            if self.system == "Windows":
                # Windows下需要特殊处理
                return True
            elif self.system == "Darwin":
                os.system("killall afplay")
                return True
            elif self.system == "Linux":
                subprocess.run(['pkill', 'paplay'])
                return True
            return False
        except Exception as e:
            logger.error(f"停止声音播放失败: {str(e)}")
            return False 
import requests
import json
from datetime import datetime, timedelta

BASE_URL = "http://localhost:8000/api/v1"

def test_create_alarm():
    """测试创建闹钟"""
    url = f"{BASE_URL}/alarms/"
    # 创建一个明天早上的闹钟
    tomorrow = datetime.now() + timedelta(days=1)
    alarm_time = tomorrow.replace(hour=7, minute=0, second=0, microsecond=0)
    
    data = {
        "time": alarm_time.isoformat(),
        "vibration": True,
        "sound": "默认铃声",
        "repeat_days": [True, True, True, True, True, False, False],  # 周一到周五
        "description": "工作日闹钟",
        "user_id": 1  # 临时使用固定用户ID
    }
    
    response = requests.post(url, json=data)
    print("\n创建闹钟响应:", response.json())
    return response.json()

def test_get_alarms():
    """测试获取闹钟列表"""
    url = f"{BASE_URL}/alarms/"
    response = requests.get(url)
    print("\n获取闹钟列表响应:", response.json())
    return response.json()

def test_update_alarm(alarm_id):
    """测试更新闹钟"""
    url = f"{BASE_URL}/alarms/{alarm_id}"
    data = {
        "is_active": False,
        "description": "已更新的闹钟"
    }
    response = requests.put(url, json=data)
    print("\n更新闹钟响应:", response.json())
    return response.json()

def test_delete_alarm(alarm_id):
    """测试删除闹钟"""
    url = f"{BASE_URL}/alarms/{alarm_id}"
    response = requests.delete(url)
    print("\n删除闹钟响应:", response.json())
    return response.json()

if __name__ == "__main__":
    print("开始API测试...")
    
    # 测试创建闹钟
    new_alarm = test_create_alarm()
    alarm_id = new_alarm.get("id")
    
    # 测试获取闹钟列表
    alarms = test_get_alarms()
    
    # 测试更新闹钟
    if alarm_id:
        updated_alarm = test_update_alarm(alarm_id)
    
    # 测试删除闹钟
    if alarm_id:
        test_delete_alarm(alarm_id)
    
    print("\nAPI测试完成") 
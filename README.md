# 智能闹钟应用开发指南

## 项目概述

这是一个基于Flutter和FastAPI的智能闹钟应用，支持多平台（Android、iOS、Windows）运行。

**功能体系设计（基础功能+增强功能）**
1. **核心提醒系统（拟声升级）**
   - **环境感知唤醒**：通过手机传感器检测光照/动作，用逐渐增强的自然音效（鸟鸣/溪流声）配合AI语音唤醒
   - **多模态提醒**：重要事项采用声（拟声）+光（屏幕渐变）+震（特定节奏）组合提醒
   - **声纹定制**：用户可录制家人声音/选择明星声线/AI合成专属语音包
2. **智能生活助手**
   - **周期性事务预测**：自动学习剪发周期（3个月后提醒），同步健康数据提醒体检
   - **通勤守护**：接入地图API，暴雨/堵车时提前30分钟用急促雨声+语音提醒
   - **睡眠管家**：睡前1小时自动切换蓝光过滤模式，用白噪音帮助入眠
3. **情境化交互设计**
   - **声控贪睡**：迷糊中说"再睡5分钟"会自动缩短间隔（防迟到模式）
   - **智能打断**：晨起播报时检测到用户打哈欠，会自动插入振奋音效
   - **多设备联动**：唤醒后自动打开智能窗帘/启动咖啡机（需IoT对接）
  
## 场景示例
当用户设置"每周三健身提醒"时：
1. 系统自动检测当日天气（高温则建议室内运动）
2. 同步手环数据（若检测到前日睡眠不足则调整提醒强度）
3. 播放私人教练预录的激励语音："今天练腿日，别忘了泡沫轴！"
4. 到达健身房地理围栏范围后自动停止提醒

## 技术栈

### 前端
- Flutter 3.x
- Provider (状态管理)
- SharedPreferences (本地存储)
- Flutter Local Notifications (本地通知)
- Just Audio (音频播放)
- Workmanager (后台任务)

### 后端
- Python 3.8+
- FastAPI
- SQLAlchemy
- SQLite
- Pydantic

## 开发环境配置

### 前端环境
1. 安装Flutter SDK
   ```bash
   # Windows
   # 下载Flutter SDK并解压到合适位置
   # 添加Flutter到环境变量
   
   # 验证安装
   flutter doctor
   ```

2. 安装开发工具
   - Android Studio
   - VS Code + Flutter插件

3. 配置Android开发环境
   - 安装Android SDK
   - 配置ANDROID_HOME环境变量
   - 创建Android模拟器或连接实体设备

### 后端环境
1. 安装Python 3.8+
   ```bash
   # 验证Python版本
   python --version
   ```

2. 创建虚拟环境
   ```bash
   # 创建虚拟环境
   python -m venv venv
   
   # 激活虚拟环境
   # Windows
   .\venv\Scripts\activate
   # Linux/Mac
   source venv/bin/activate
   ```

3. 安装依赖
   ```bash
   pip install -r requirements.txt
   ```

## 项目结构

```
smart_alarm/
├── frontend/                # Flutter前端项目
│   ├── lib/
│   │   ├── models/         # 数据模型
│   │   ├── providers/      # 状态管理
│   │   ├── screens/        # 页面
│   │   ├── services/       # 服务
│   │   ├── widgets/        # 组件
│   │   └── main.dart       # 入口文件
│   └── pubspec.yaml        # 依赖配置
│
└── backend/                # FastAPI后端项目
    ├── app/
    │   ├── api/           # API路由
    │   ├── models/        # 数据库模型
    │   ├── schemas/       # Pydantic模型
    │   ├── services/      # 业务逻辑
    │   └── main.py        # 入口文件
    └── requirements.txt    # 依赖配置
```

## 开发流程

### 前端开发
1. 启动开发服务器
   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```

2. 调试技巧
   - 使用Flutter DevTools进行性能分析
   - 使用Hot Reload快速预览修改
   - 使用Flutter Inspector检查UI

3. 发布准备
   ```bash
   flutter build apk  # Android
   flutter build ios  # iOS
   flutter build windows  # Windows
   ```

### 后端开发
1. 启动开发服务器
   ```bash
   cd backend
   uvicorn app.main:app --reload
   ```

2. API文档
   - 访问 http://localhost:8000/docs 查看Swagger文档
   - 访问 http://localhost:8000/redoc 查看ReDoc文档

3. 数据库迁移
   ```bash
   # 创建迁移
   alembic revision --autogenerate -m "描述"
   
   # 应用迁移
   alembic upgrade head
   ```

## 常见问题

### 前端问题
1. 依赖冲突
   - 检查pubspec.yaml中的版本约束
   - 使用flutter pub outdated检查过时依赖
   - 运行flutter clean后重新安装依赖

2. 平台特定问题
   - Android: 检查AndroidManifest.xml权限配置
   - iOS: 检查Info.plist配置
   - Windows: 确保启用开发者模式

### 后端问题
1. 数据库连接
   - 检查DATABASE_URL环境变量
   - 确保数据库文件权限正确
   - 检查SQLite连接参数

2. 依赖问题
   - 使用虚拟环境隔离依赖
   - 定期更新requirements.txt
   - 检查Python版本兼容性

## 最佳实践

### 代码规范
1. 前端
   - 遵循Flutter官方风格指南
   - 使用Provider进行状态管理
   - 保持widget树扁平化
   - 使用const构造函数

2. 后端
   - 遵循PEP 8规范
   - 使用类型注解
   - 编写单元测试
   - 使用异步编程

### 性能优化
1. 前端
   - 使用const widgets
   - 实现懒加载
   - 优化图片资源
   - 使用缓存机制

2. 后端
   - 使用连接池
   - 实现缓存层
   - 优化数据库查询
   - 使用异步处理

### 安全实践
1. 前端
   - 使用HTTPS
   - 实现数据加密
   - 防止XSS攻击
   - 保护敏感信息

2. 后端
   - 实现身份验证
   - 使用CORS保护
   - 参数验证
   - 错误处理

## 贡献指南

1. Fork项目
2. 创建特性分支
3. 提交更改
4. 推送到分支
5. 创建Pull Request

## 许可证

MIT License

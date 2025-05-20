import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart';
import 'package:flutter/foundation.dart';

/// 闹钟服务类
/// 
/// 负责处理闹钟的核心功能，包括：
/// - 闹钟的创建、取消
/// - 闹钟提醒（声音、震动）
/// - 本地通知
/// - 后台任务
class AlarmService {
  /// 单例实例
  static final AlarmService _instance = AlarmService._internal();
  
  /// 工厂构造函数，返回单例实例
  factory AlarmService() => _instance;
  
  /// 私有构造函数
  AlarmService._internal();

  /// 本地通知插件实例
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  /// 音频播放器实例
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  /// 后台任务管理器实例
  final Workmanager _workmanager = Workmanager();
  
  /// 初始化状态标志
  bool _isInitialized = false;

  /// 初始化服务
  /// 
  /// 初始化本地通知、后台任务等组件
  /// 在应用启动时调用
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 初始化通知
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(initSettings);

    // 初始化后台任务（仅在移动平台）
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _workmanager.initialize(callbackDispatcher);
      await _workmanager.registerPeriodicTask(
        'alarm_check',
        'checkAlarms',
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
    }

    _isInitialized = true;
  }

  /// 创建闹钟
  /// 
  /// [id] 闹钟ID
  /// [time] 闹钟时间
  /// [sound] 闹钟声音文件名
  /// [vibration] 是否震动
  /// [repeatDays] 重复日期列表（周一到周日）
  /// [description] 闹钟描述
  Future<void> scheduleAlarm({
    required int id,
    required DateTime time,
    required String sound,
    required bool vibration,
    required List<bool> repeatDays,
    String? description,
  }) async {
    // 设置通知
    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      '闹钟提醒',
      channelDescription: '闹钟提醒通知',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(sound),
      enableVibration: vibration,
    );
    final iosDetails = DarwinNotificationDetails(
      sound: sound,
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 设置重复
    if (repeatDays.any((day) => day)) {
      for (int i = 0; i < 7; i++) {
        if (repeatDays[i]) {
          final scheduledTime = _getNextAlarmTime(time, i);
          await _notifications.zonedSchedule(
            id * 10 + i,
            '闹钟提醒',
            description ?? '该起床了！',
            scheduledTime,
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }
    } else {
      await _notifications.zonedSchedule(
        id,
        '闹钟提醒',
        description ?? '该起床了！',
        TZDateTime.from(time, local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // 保存闹钟信息
    final prefs = await SharedPreferences.getInstance();
    final alarms = prefs.getStringList('alarms') ?? [];
    alarms.add(jsonEncode({
      'id': id,
      'time': time.toIso8601String(),
      'sound': sound,
      'vibration': vibration,
      'repeatDays': repeatDays,
      'description': description,
    }));
    await prefs.setStringList('alarms', alarms);
  }

  /// 取消闹钟
  /// 
  /// [id] 要取消的闹钟ID
  Future<void> cancelAlarm(int id) async {
    // 取消通知
    if (id > 0) {
      await _notifications.cancel(id);
      // 取消重复闹钟
      for (int i = 0; i < 7; i++) {
        await _notifications.cancel(id * 10 + i);
      }
    }

    // 从存储中移除
    final prefs = await SharedPreferences.getInstance();
    final alarms = prefs.getStringList('alarms') ?? [];
    alarms.removeWhere((alarm) {
      final data = jsonDecode(alarm);
      return data['id'] == id;
    });
    await prefs.setStringList('alarms', alarms);
  }

  /// 播放闹钟声音
  /// 
  /// [sound] 声音文件名
  Future<void> playAlarmSound(String sound) async {
    try {
      await _audioPlayer.setAsset('assets/sounds/心墙.mp3');
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
    } catch (e) {
      print('播放声音失败: $e');
    }
  }

  /// 停止闹钟声音
  Future<void> stopAlarmSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('停止声音失败: $e');
    }
  }

  /// 触发震动
  Future<void> vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000, repeat: 0);
    }
  }

  /// 停止震动
  Future<void> stopVibration() async {
    Vibration.cancel();
  }

  /// 计算下一次闹钟时间
  /// 
  /// [time] 闹钟时间
  /// [weekday] 星期几（0-6，0表示周一）
  /// 返回下一次闹钟的时区时间
  TZDateTime _getNextAlarmTime(DateTime time, int weekday) {
    final now = TZDateTime.now(local);
    var scheduledTime = TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // 调整到下一个指定的星期几
    while (scheduledTime.weekday != weekday + 1) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // 如果时间已经过去，调整到下周
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 7));
    }

    return scheduledTime;
  }
}

/// 后台任务回调函数
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'checkAlarms') {
      // 检查闹钟
      final prefs = await SharedPreferences.getInstance();
      final alarms = prefs.getStringList('alarms') ?? [];
      final now = DateTime.now();

      for (final alarmStr in alarms) {
        final alarm = jsonDecode(alarmStr);
        final alarmTime = DateTime.parse(alarm['time']);
        
        if (_shouldTriggerAlarm(alarmTime, alarm['repeatDays'])) {
          // 触发闹钟
          final service = AlarmService();
          await service.playAlarmSound(alarm['sound']);
          if (alarm['vibration']) {
            await service.vibrate();
          }
        }
      }
    }
    return true;
  });
}

/// 检查是否应该触发闹钟
/// 
/// [alarmTime] 闹钟时间
/// [repeatDays] 重复日期列表
/// 返回是否应该触发闹钟
bool _shouldTriggerAlarm(DateTime alarmTime, List<bool> repeatDays) {
  final now = DateTime.now();
  if (alarmTime.hour == now.hour && alarmTime.minute == now.minute) {
    if (repeatDays.isEmpty) return true;
    return repeatDays[now.weekday - 1];
  }
  return false;
} 
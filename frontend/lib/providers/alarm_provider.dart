import 'package:flutter/foundation.dart';
import '../models/alarm.dart';
import '../repositories/alarm_repository.dart';
import '../services/alarm_service.dart';

class AlarmProvider with ChangeNotifier {
  final AlarmRepository _repository;
  final AlarmService _service;
  List<Alarm> _alarms = [];
  bool _isLoading = false;

  AlarmProvider(this._repository, this._service);

  List<Alarm> get alarms => _alarms;
  bool get isLoading => _isLoading;

  Future<void> loadAlarms() async {
    _isLoading = true;
    notifyListeners();

    try {
      _alarms = await _repository.getAllAlarms();
    } catch (e) {
      print('加载闹钟失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAlarm({
    required DateTime time,
    required String sound,
    required bool vibration,
    required List<bool> repeatDays,
    String? description,
  }) async {
    try {
      final id = await _repository.getNextAlarmId();
      final alarm = Alarm(
        id: id,
        time: time,
        sound: sound,
        vibration: vibration,
        repeatDays: repeatDays,
        description: description,
      );

      await _repository.saveAlarm(alarm);
      await _service.scheduleAlarm(
        id: alarm.id,
        time: alarm.time,
        sound: alarm.sound,
        vibration: alarm.vibration,
        repeatDays: alarm.repeatDays,
        description: alarm.description,
      );

      _alarms.add(alarm);
      notifyListeners();
    } catch (e) {
      print('添加闹钟失败: $e');
      rethrow;
    }
  }

  Future<void> updateAlarm(Alarm alarm) async {
    try {
      await _repository.updateAlarm(alarm);
      await _service.cancelAlarm(alarm.id);
      
      if (alarm.isEnabled) {
        await _service.scheduleAlarm(
          id: alarm.id,
          time: alarm.time,
          sound: alarm.sound,
          vibration: alarm.vibration,
          repeatDays: alarm.repeatDays,
          description: alarm.description,
        );
      }

      final index = _alarms.indexWhere((a) => a.id == alarm.id);
      if (index >= 0) {
        _alarms[index] = alarm;
        notifyListeners();
      }
    } catch (e) {
      print('更新闹钟失败: $e');
      rethrow;
    }
  }

  Future<void> deleteAlarm(int id) async {
    try {
      await _repository.deleteAlarm(id);
      await _service.cancelAlarm(id);
      
      _alarms.removeWhere((alarm) => alarm.id == id);
      notifyListeners();
    } catch (e) {
      print('删除闹钟失败: $e');
      rethrow;
    }
  }

  Future<void> toggleAlarm(int id, bool enabled) async {
    try {
      await _repository.toggleAlarm(id, enabled);
      
      final index = _alarms.indexWhere((a) => a.id == id);
      if (index >= 0) {
        final alarm = _alarms[index];
        if (enabled) {
          await _service.scheduleAlarm(
            id: alarm.id,
            time: alarm.time,
            sound: alarm.sound,
            vibration: alarm.vibration,
            repeatDays: alarm.repeatDays,
            description: alarm.description,
          );
        } else {
          await _service.cancelAlarm(id);
        }
        
        _alarms[index] = alarm.copyWith(isEnabled: enabled);
        notifyListeners();
      }
    } catch (e) {
      print('切换闹钟状态失败: $e');
      rethrow;
    }
  }

  Future<void> playAlarmSound(String sound) async {
    await _service.playAlarmSound(sound);
  }

  Future<void> stopAlarmSound() async {
    await _service.stopAlarmSound();
  }

  Future<void> vibrate() async {
    await _service.vibrate();
  }

  Future<void> stopVibration() async {
    await _service.stopVibration();
  }
} 
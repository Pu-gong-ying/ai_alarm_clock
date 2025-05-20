import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';

class AlarmRepository {
  static const String _storageKey = 'alarms';
  final SharedPreferences _prefs;

  AlarmRepository(this._prefs);

  Future<List<Alarm>> getAllAlarms() async {
    final alarmsJson = _prefs.getStringList(_storageKey) ?? [];
    return alarmsJson
        .map((json) => Alarm.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveAlarm(Alarm alarm) async {
    final alarms = await getAllAlarms();
    final index = alarms.indexWhere((a) => a.id == alarm.id);
    
    if (index >= 0) {
      alarms[index] = alarm;
    } else {
      alarms.add(alarm);
    }

    await _saveAlarms(alarms);
  }

  Future<void> deleteAlarm(int id) async {
    final alarms = await getAllAlarms();
    alarms.removeWhere((alarm) => alarm.id == id);
    await _saveAlarms(alarms);
  }

  Future<void> updateAlarm(Alarm alarm) async {
    final alarms = await getAllAlarms();
    final index = alarms.indexWhere((a) => a.id == alarm.id);
    
    if (index >= 0) {
      alarms[index] = alarm;
      await _saveAlarms(alarms);
    }
  }

  Future<void> toggleAlarm(int id, bool enabled) async {
    final alarms = await getAllAlarms();
    final index = alarms.indexWhere((a) => a.id == id);
    
    if (index >= 0) {
      alarms[index] = alarms[index].copyWith(isEnabled: enabled);
      await _saveAlarms(alarms);
    }
  }

  Future<int> getNextAlarmId() async {
    final alarms = await getAllAlarms();
    if (alarms.isEmpty) return 1;
    return alarms.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> _saveAlarms(List<Alarm> alarms) async {
    final alarmsJson = alarms
        .map((alarm) => jsonEncode(alarm.toJson()))
        .toList();
    await _prefs.setStringList(_storageKey, alarmsJson);
  }
} 
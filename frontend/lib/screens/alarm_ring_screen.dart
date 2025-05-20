import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm.dart';

class AlarmRingScreen extends StatefulWidget {
  final Alarm alarm;

  const AlarmRingScreen({
    Key? key,
    required this.alarm,
  }) : super(key: key);

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  @override
  void initState() {
    super.initState();
    _startAlarm();
  }

  @override
  void dispose() {
    _stopAlarm();
    super.dispose();
  }

  Future<void> _startAlarm() async {
    final provider = context.read<AlarmProvider>();
    await provider.playAlarmSound(widget.alarm.sound);
    if (widget.alarm.vibration) {
      await provider.vibrate();
    }
  }

  Future<void> _stopAlarm() async {
    final provider = context.read<AlarmProvider>();
    await provider.stopAlarmSound();
    await provider.stopVibration();
  }

  @override
  Widget build(BuildContext context) {
    final timeOfDay = TimeOfDay.fromDateTime(widget.alarm.time);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.alarm,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 32),
              Text(
                '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (widget.alarm.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.alarm.description!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.snooze,
                    label: '稍后提醒',
                    onPressed: () {
                      _handleSnooze();
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.stop,
                    label: '停止',
                    onPressed: () {
                      _handleStop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.large(
          onPressed: onPressed,
          backgroundColor: Colors.white,
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSnooze() async {
    await _stopAlarm();
    // TODO: 实现稍后提醒功能
    Navigator.pop(context);
  }

  Future<void> _handleStop() async {
    await _stopAlarm();
    Navigator.pop(context);
  }
} 
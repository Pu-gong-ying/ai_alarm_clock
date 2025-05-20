import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm.dart';

class AlarmEditScreen extends StatefulWidget {
  final Alarm? alarm;

  const AlarmEditScreen({
    Key? key,
    this.alarm,
  }) : super(key: key);

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  late TimeOfDay _time;
  late String _sound;
  late bool _vibration;
  late List<bool> _repeatDays;
  late TextEditingController _descriptionController;
  final List<String> _availableSounds = [
    'alarm1',
    'alarm2',
    'alarm3',
    'bell',
    'chime',
  ];

  @override
  void initState() {
    super.initState();
    _time = widget.alarm != null
        ? TimeOfDay.fromDateTime(widget.alarm!.time)
        : TimeOfDay.now();
    _sound = widget.alarm?.sound ?? 'alarm1';
    _vibration = widget.alarm?.vibration ?? true;
    _repeatDays = widget.alarm?.repeatDays ?? List.filled(7, false);
    _descriptionController = TextEditingController(
      text: widget.alarm?.description,
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? '添加闹钟' : '编辑闹钟'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAlarm,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTimePicker(),
          const SizedBox(height: 24),
          _buildSoundPicker(),
          const SizedBox(height: 16),
          _buildVibrationSwitch(),
          const SizedBox(height: 16),
          _buildRepeatDays(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _showTimePicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '闹钟声音',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _sound,
            isExpanded: true,
            underline: const SizedBox(),
            items: _availableSounds.map((String sound) {
              return DropdownMenuItem<String>(
                value: sound,
                child: Text(sound),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _sound = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVibrationSwitch() {
    return SwitchListTile(
      title: const Text('震动'),
      value: _vibration,
      onChanged: (bool value) {
        setState(() {
          _vibration = value;
        });
      },
    );
  }

  Widget _buildRepeatDays() {
    const days = ['日', '一', '二', '三', '四', '五', '六'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '重复',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            return InkWell(
              onTap: () {
                setState(() {
                  _repeatDays[index] = !_repeatDays[index];
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _repeatDays[index]
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: _repeatDays[index]
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: _repeatDays[index] ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: '备注',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  void _saveAlarm() {
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      _time.hour,
      _time.minute,
    );

    final provider = context.read<AlarmProvider>();
    if (widget.alarm == null) {
      provider.addAlarm(
        time: alarmTime,
        sound: _sound,
        vibration: _vibration,
        repeatDays: _repeatDays,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );
    } else {
      provider.updateAlarm(
        widget.alarm!.copyWith(
          time: alarmTime,
          sound: _sound,
          vibration: _vibration,
          repeatDays: _repeatDays,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
        ),
      );
    }

    Navigator.pop(context);
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';

class CreateAlarmScreen extends StatefulWidget {
  const CreateAlarmScreen({super.key});

  @override
  State<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends State<CreateAlarmScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _vibration = true;
  String _selectedSound = '默认铃声';
  final List<bool> _repeatDays = List.generate(7, (index) => false);
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建闹钟'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 保存闹钟
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 时间选择
          ListTile(
            title: const Text('时间'),
            trailing: TextButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) {
                  setState(() {
                    _selectedTime = picked;
                  });
                }
              },
              child: Text(
                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const Divider(),

          // 重复选项
          const Text('重复', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final days = ['一', '二', '三', '四', '五', '六', '日'];
              return ChoiceChip(
                label: Text(days[index]),
                selected: _repeatDays[index],
                onSelected: (selected) {
                  setState(() {
                    _repeatDays[index] = selected;
                  });
                },
              );
            }),
          ),
          const Divider(),

          // 提醒方式
          SwitchListTile(
            title: const Text('震动'),
            value: _vibration,
            onChanged: (value) {
              setState(() {
                _vibration = value;
              });
            },
          ),
          ListTile(
            title: const Text('铃声'),
            trailing: DropdownButton<String>(
              value: _selectedSound,
              items: const [
                DropdownMenuItem(value: '默认铃声', child: Text('默认铃声')),
                DropdownMenuItem(value: '轻柔铃声', child: Text('轻柔铃声')),
                DropdownMenuItem(value: '活力铃声', child: Text('活力铃声')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSound = value;
                  });
                }
              },
            ),
          ),
          const Divider(),

          // 备注
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '备注',
              hintText: '添加备注（可选）',
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
} 
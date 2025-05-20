import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm.dart';
import 'alarm_edit_screen.dart';

class AlarmListScreen extends StatelessWidget {
  const AlarmListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的闹钟'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 实现设置页面导航
            },
          ),
        ],
      ),
      body: Consumer<AlarmProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.alarms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.alarm_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '还没有闹钟',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _addAlarm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('添加闹钟'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.alarms.length,
            itemBuilder: (context, index) {
              final alarm = provider.alarms[index];
              return _AlarmListTile(alarm: alarm);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addAlarm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addAlarm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AlarmEditScreen(),
      ),
    );
  }
}

class _AlarmListTile extends StatelessWidget {
  final Alarm alarm;

  const _AlarmListTile({
    Key? key,
    required this.alarm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AlarmProvider>();
    final timeOfDay = TimeOfDay.fromDateTime(alarm.time);

    return Dismissible(
      key: Key('alarm_${alarm.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        provider.deleteAlarm(alarm.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('闹钟已删除'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: ListTile(
        leading: Switch(
          value: alarm.isEnabled,
          onChanged: (value) {
            provider.toggleAlarm(alarm.id, value);
          },
        ),
        title: Text(
          '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alarm.description != null)
              Text(alarm.description!),
            const SizedBox(height: 4),
            Row(
              children: [
                if (alarm.repeatDays.any((day) => day))
                  const Icon(Icons.repeat, size: 16),
                if (alarm.vibration)
                  const Icon(Icons.vibration, size: 16),
                if (alarm.sound.isNotEmpty)
                  const Icon(Icons.volume_up, size: 16),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlarmEditScreen(alarm: alarm),
              ),
            );
          },
        ),
      ),
    );
  }
} 
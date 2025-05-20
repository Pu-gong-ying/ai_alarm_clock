import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';

class AlarmList extends StatelessWidget {
  const AlarmList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlarmProvider>(
      builder: (context, alarmProvider, child) {
        final alarms = alarmProvider.alarms;
        
        if (alarms.isEmpty) {
          return const Center(
            child: Text(
              '暂无闹钟\n点击右下角添加',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: alarms.length,
          itemBuilder: (context, index) {
            final alarm = alarms[index];
            return Dismissible(
              key: Key(alarm.id.toString()),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16.0),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                alarmProvider.deleteAlarm(alarm.id);
              },
              child: ListTile(
                leading: Switch(
                  value: alarm.isActive,
                  onChanged: (value) {
                    alarmProvider.toggleAlarm(alarm.id);
                  },
                ),
                title: Text(
                  '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  alarm.description ?? '无备注',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: 编辑闹钟
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
} 
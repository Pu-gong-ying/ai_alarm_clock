import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'providers/alarm_provider.dart';
import 'repositories/alarm_repository.dart';
import 'services/alarm_service.dart';
import 'screens/alarm_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化时区数据
  tz.initializeTimeZones();
  
  final prefs = await SharedPreferences.getInstance();
  final repository = AlarmRepository(prefs);
  final service = AlarmService();
  await service.initialize();

  runApp(MyApp(
    repository: repository,
    service: service,
  ));
}

class MyApp extends StatelessWidget {
  final AlarmRepository repository;
  final AlarmService service;

  const MyApp({
    Key? key,
    required this.repository,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AlarmProvider(repository, service),
        ),
      ],
      child: MaterialApp(
        title: '智能闹钟',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const AlarmListScreen(),
      ),
    );
  }
} 
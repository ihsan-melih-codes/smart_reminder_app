import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/reminder.dart';
import 'screens/add_note_screen.dart';
import 'screens/home_screen.dart';
import 'screens/info_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ReminderAdapter());
  }
  await Hive.openBox<Reminder>('remindersBox');
  await NotificationService.init();

  runApp(const SmartReminderApp());
}

class SmartReminderApp extends StatelessWidget {
  const SmartReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Reminder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF376E6F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add': (context) => const AddNoteScreen(),
        '/info': (context) => const InfoScreen(),
      },
    );
  }
}

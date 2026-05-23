import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:smart_reminder_app/main.dart';
import 'package:smart_reminder_app/models/reminder.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('smart_reminder_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ReminderAdapter());
    }
    await Hive.openBox<Reminder>('remindersBox');
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('Uygulama temel arayuz testi', (tester) async {
    await tester.pumpWidget(const SmartReminderApp());

    expect(find.text('Smart Reminder'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Henüz hatırlatıcı eklenmedi.'), findsOneWidget);
  });
}

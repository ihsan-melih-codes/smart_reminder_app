import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../widgets/custom_design_container.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descController = TextEditingController();
  DateTime selectedDate = DateTime.now().add(const Duration(minutes: 5));
  String selectedPriority = 'Orta';
  bool _isSaving = false;

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.isBefore(now) ? now : selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );
    if (pickedTime == null || !mounted) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() => selectedDate = newDateTime);

    if (newDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Lütfen gelecekte bir saat seçin.')),
        );
    }
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    if (!selectedDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Hatırlatma zamanı gelecekte olmalı.')),
        );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final reminder = Reminder(
        title: titleController.text.trim(),
        description: descController.text.trim(),
        dateTime: selectedDate,
        priority: selectedPriority,
      );

      var permissionsGranted = false;
      if (NotificationService.isSupported) {
        try {
          permissionsGranted = await NotificationService.requestPermissions();
        } catch (_) {
          permissionsGranted = false;
        }
      }

      if (!mounted) return;
      final box = Hive.box<Reminder>('remindersBox');
      final key = await box.add(reminder);
      var message = !NotificationService.isSupported
          ? 'Hatırlatıcı kaydedildi. Web sürümünde yerel bildirim desteklenmez.'
          : permissionsGranted
              ? 'Hatırlatıcı kaydedildi ve bildirim kuruldu.'
              : 'Hatırlatıcı kaydedildi ancak bildirim izinleri verilmedi. Bildirim göndermek için izinleri açın.';

      if (NotificationService.isSupported && permissionsGranted) {
        try {
          await NotificationService.scheduleNotification(
            id: key,
            title: 'Hatırlatıcı: ${reminder.title}',
            body: reminder.description,
            scheduledDate: reminder.dateTime,
          );
        } catch (_) {
          message =
              'Hatırlatıcı kaydedildi ancak bildirim kurulamadı. Bildirim izinlerini kontrol edin.';
        }
      }

      if (!mounted) return;
      Navigator.pop(context, message);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Hatırlatıcı kaydedilemedi. Lütfen tekrar deneyin.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(dateTime.day)}.${twoDigits(dateTime.month)}.${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Hatırlatıcı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomDesignContainer(
                child: TextFormField(
                  controller: titleController,
                  maxLength: 80,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Başlık',
                    icon: Icon(Icons.edit_outlined),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen başlık girin';
                    }
                    return null;
                  },
                ),
              ),
              CustomDesignContainer(
                child: TextFormField(
                  controller: descController,
                  maxLength: 500,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    icon: Icon(Icons.description_outlined),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen açıklama girin';
                    }
                    return null;
                  },
                ),
              ),
              CustomDesignContainer(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Öncelik',
                    icon: Icon(Icons.flag_outlined),
                    border: InputBorder.none,
                  ),
                  items: ['Düşük', 'Orta', 'Yüksek']
                      .map(
                        (priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedPriority = value);
                  },
                ),
              ),
              CustomDesignContainer(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_outlined),
                  title: Text(_formatDate(selectedDate)),
                  subtitle: Text(_formatTime(selectedDate)),
                  trailing: TextButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.edit_calendar_outlined),
                    label: const Text('Zaman seç'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Kaydediliyor…' : 'Kaydet ve bildirimi kur'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

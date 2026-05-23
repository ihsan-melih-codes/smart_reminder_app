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

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );
    if (pickedTime == null) return;

    setState(() {
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final reminder = Reminder(
      title: titleController.text.trim(),
      description: descController.text.trim(),
      dateTime: selectedDate,
      priority: selectedPriority,
    );

    final box = Hive.box<Reminder>('remindersBox');
    final key = await box.add(reminder);

    await NotificationService.scheduleNotification(
      id: key,
      title: 'Hatırlatıcı: ${reminder.title}',
      body: reminder.description,
      scheduledDate: reminder.dateTime,
    );

    if (!mounted) return;

    final message = NotificationService.isSupported
        ? 'Hatırlatıcı kaydedildi ve bildirim kuruldu.'
        : 'Hatırlatıcı kaydedildi. Web sürümünde yerel bildirim desteklenmez.';
    Navigator.pop(context, message);
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
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Kaydet ve bildirimi kur'),
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

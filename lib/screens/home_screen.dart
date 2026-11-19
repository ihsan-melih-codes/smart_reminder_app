import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/reminder.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Reminder> reminderBox;
  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    reminderBox = Hive.box<Reminder>('remindersBox');
    _searchController.addListener(() {
      setState(() => _searchText = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddScreen() async {
    final message = await Navigator.pushNamed(context, '/add') as String?;
    if (!mounted || message == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete(Box<Reminder> box, _ReminderEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hatırlatıcı silinsin mi?'),
        content: Text('"' + entry.reminder.title + '" kalıcı olarak silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await box.delete(entry.key);
    await NotificationService.cancelNotification(entry.key);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Hatırlatıcı silindi.')),
      );
  }

  List<_ReminderEntry> _visibleItems(Box<Reminder> box) {
    final entries = box.keys.map((key) {
      return _ReminderEntry(key as int, box.get(key)!);
    }).toList();

    entries.sort((a, b) => a.reminder.dateTime.compareTo(b.reminder.dateTime));

    if (_searchText.isEmpty) return entries;

    return entries.where((entry) {
      final reminder = entry.reminder;
      return reminder.title.toLowerCase().contains(_searchText) ||
          reminder.description.toLowerCase().contains(_searchText) ||
          reminder.priority.toLowerCase().contains(_searchText);
    }).toList();
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Yüksek':
        return const Color(0xFFC0392B);
      case 'Düşük':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFFB26A00);
    }
  }

  String _formatDate(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(dateTime.day)}.${twoDigits(dateTime.month)}.${dateTime.year} '
        '${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Reminder'), centerTitle: true),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const ListTile(
                title: Text(
                  'Smart Reminder',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Mobil Programlama II ödevi'),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Hatırlatıcılar'),
                selected: true,
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.add_alert_outlined),
                title: const Text('Yeni Hatırlatıcı'),
                onTap: () {
                  Navigator.pop(context);
                  _openAddScreen();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Ödev Bilgisi'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/info');
                },
              ),
            ],
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: reminderBox.listenable(),
        builder: (context, Box<Reminder> box, _) {
          final items = _visibleItems(box);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Başlık, açıklama veya öncelik ara',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchText.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Aramayı temizle',
                          onPressed: _searchController.clear,
                          icon: const Icon(Icons.close),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                _EmptyState(
                  hasSearch: _searchText.isNotEmpty,
                  onAddPressed: _openAddScreen,
                )
              else
                ...items.map((entry) {
                  final reminder = entry.reminder;
                  final color = _priorityColor(reminder.priority);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.12),
                        child: Icon(Icons.notifications_active, color: color),
                      ),
                      title: Text(
                        reminder.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${reminder.description}\n'
                          'Zaman: ${_formatDate(reminder.dateTime)}\n'
                          'Öncelik: ${reminder.priority}',
                        ),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: 'Sil',
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red.shade700,
                        onPressed: () => _confirmDelete(box, entry),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddScreen,
        icon: const Icon(Icons.add),
        label: const Text('Yeni'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearch, required this.onAddPressed});

  final bool hasSearch;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.event_note_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch
                ? 'Aramanla eşleşen hatırlatıcı yok.'
                : 'Henüz hatırlatıcı eklenmedi.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (!hasSearch)
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add_alert),
              label: const Text('İlk hatırlatıcıyı ekle'),
            ),
        ],
      ),
    );
  }
}

class _ReminderEntry {
  const _ReminderEntry(this.key, this.reminder);

  final int key;
  final Reminder reminder;
}

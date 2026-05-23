import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _InfoItem(
        icon: Icons.screenshot_monitor_outlined,
        title: 'Birden fazla ekran',
        description:
            'Ana ekran, yeni hatırlatıcı ekranı ve ödev bilgisi ekranı bulunur.',
      ),
      _InfoItem(
        icon: Icons.menu_open_outlined,
        title: 'Aktif menü',
        description: 'Yan menüden ekranlar arasında geçiş yapılır.',
      ),
      _InfoItem(
        icon: Icons.sync_alt_outlined,
        title: 'Stateful yapı',
        description:
            'Hatırlatıcı ekleme, arama ve listeleme işlemleri durum yönetimi kullanır.',
      ),
      _InfoItem(
        icon: Icons.storage_outlined,
        title: 'Kalıcı kayıt',
        description: 'Hatırlatıcılar Hive veritabanında saklanır.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Ödev Bilgisi')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text(
              'Smart Reminder, Mobil Programlama II ödevi için hazırlanmış '
              'durumlu ve çok ekranlı bir hatırlatıcı uygulamasıdır. Android '
              'sürümünde yerel bildirim kurar; web sürümünde kayıt ve arama '
              'özellikleri tarayıcı üzerinden kullanılabilir.',
              style: Theme.of(context).textTheme.bodyLarge,
            );
          }

          final item = items[index - 1];
          return Card(
            child: ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              subtitle: Text(item.description),
            ),
          );
        },
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

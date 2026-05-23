class NotificationService {
  static bool get isSupported => false;

  static Future<void> init() async {}

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {}

  static Future<void> cancelNotification(int id) async {}
}

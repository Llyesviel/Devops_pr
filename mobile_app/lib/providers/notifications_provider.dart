import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/microservices_client.dart';

class NotificationsProvider with ChangeNotifier {
  final MicroservicesClient _client = MicroservicesClient();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  Map<String, bool> _servicesHealth = {};

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, bool> get servicesHealth => _servicesHealth;

  // Получить историю уведомлений
  Future<void> fetchNotifications({
    int limit = 50,
    int offset = 0,
    String? type,
    bool? isRead,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final notificationsData = await _client.getNotificationHistory(
        limit: limit,
        offset: offset,
        type: type,
        isRead: isRead,
      );
      
      _notifications = notificationsData
          .map((data) => NotificationModel.fromJson(data))
          .toList();
          
    } on Exception catch (e) {
      _error = 'Ошибка загрузки уведомлений: ${e.toString()}';
      _notifications = [];
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Отправить уведомление
  Future<bool> sendNotification({
    required String title,
    required String message,
    String type = 'info',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _client.sendNotification(
        title: title,
        message: message,
        type: type,
      );
      
      // Обновляем список уведомлений
      await fetchNotifications();
      return true;
    } on Exception catch (e) {
      _error = 'Ошибка отправки уведомления: ${e.toString()}';
      debugPrint('Error sending notification: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Отметить уведомление как прочитанное
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _client.markNotificationAsRead(notificationId);
      
      // Обновляем локальный список
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
      
      return true;
    } on Exception catch (e) {
      _error = 'Ошибка обновления уведомления: ${e.toString()}';
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  // Добавить уведомление локально (для WebSocket)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Очистить ошибку
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Проверить статус сервисов
  Future<void> checkServicesHealth() async {
    try {
      _servicesHealth = await _client.checkServicesHealth();
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error checking services health: $e');
      _servicesHealth = {
        'animal_service': false,
        'notification_service': false,
      };
      notifyListeners();
    }
  }

  // Получить количество непрочитанных уведомлений
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Очистить все уведомления
  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Получить уведомления по типу
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Отметить все уведомления как прочитанные
  Future<void> markAllAsRead() async {
    try {
      for (final notification in _notifications.where((n) => !n.isRead)) {
        await markAsRead(notification.id);
      }
    } on Exception catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }
}
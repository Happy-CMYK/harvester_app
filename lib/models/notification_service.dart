class NotificationService {
  static final List<AppNotification> _notifications = [];
  
  /// 发送订单相关通知
  static Future<bool> sendOrderNotification({
    required String userId,
    required String title,
    required String content,
    String type = 'order',
  }) async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 300));
    
    final notification = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      content: content,
      type: type,
      createdAt: DateTime.now(),
    );
    
    _notifications.add(notification);
    print('🔔 发送通知给用户 $userId: $title - $content');
    return true;
  }
  
  /// 发送系统通知
  static Future<bool> sendSystemNotification({
    required String userId,
    required String title,
    required String content,
  }) async {
    return await sendOrderNotification(
      userId: userId,
      title: title,
      content: content,
      type: 'system',
    );
  }
  
  /// 获取用户未读通知数量
  static int getUnreadCount(String userId) {
    return _notifications
        .where((notif) => notif.userId == userId && !notif.isRead)
        .length;
  }
  
  /// 获取用户所有通知
  static List<AppNotification> getUserNotifications(String userId) {
    return _notifications
        .where((notif) => notif.userId == userId)
        .toList();
  }
  
  /// 标记通知为已读
  static void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((notif) => notif.id == notificationId);
    if (index != -1) {
      _notifications[index] = AppNotification(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        title: _notifications[index].title,
        content: _notifications[index].content,
        type: _notifications[index].type,
        isRead: true,
        createdAt: _notifications[index].createdAt,
      );
    }
  }
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String type; // 'order', 'system', 'payment'
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
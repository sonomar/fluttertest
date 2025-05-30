// NotificationModel represents a general notification.
class NotificationModel {
  final int id;
  final DateTime createdDt;
  final bool enabled;
  final String title;
  final String message;

  NotificationModel({
    required this.id,
    required this.createdDt,
    required this.enabled,
    required this.title,
    required this.message,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      createdDt: DateTime.parse(json['createdDt']),
      enabled: json['enabled'],
      title: json['title'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdDt': createdDt.toIso8601String(),
      'enabled': enabled,
      'title': title,
      'message': message,
    };
  }
}

// UserNotification represents user-specific metadata for notifications.
class UserNotification {
  final int id;
  bool deleted; // Mutable for state updates
  final bool archived;
  final int userId;
  final int notificationId;
  bool markRead; // Mutable for state updates

  UserNotification({
    required this.id,
    required this.deleted,
    required this.archived,
    required this.userId,
    required this.notificationId,
    required this.markRead,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'],
      deleted: json['deleted'],
      archived: json['archived'],
      userId: json['userId'],
      notificationId: json['notificationId'],
      markRead: json['markRead'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deleted': deleted,
      'archived': archived,
      'userId': userId,
      'notificationId': notificationId,
      'markRead': markRead,
    };
  }
}
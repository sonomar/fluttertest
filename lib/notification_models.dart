// Represents a general notification that can be sent to users.
class NotificationModel {
  final int id; // Unique identifier for the notification
  final DateTime createdDt; // Date the notification was created
  final bool enabled; // Indicates if the notification is active
  final String title; // Title of the notification
  final String message; // Full message content

  NotificationModel({
    required this.id,
    required this.createdDt,
    required this.enabled,
    required this.title,
    required this.message,
  });

  // Creates a NotificationModel from a JSON map
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      createdDt: DateTime.parse(json['createdDt']), // Convert string to DateTime
      enabled: json['enabled'],
      title: json['title'],
      message: json['message'],
    );
  }

  // Converts the NotificationModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdDt': createdDt.toIso8601String(), // Convert DateTime to ISO string
      'enabled': enabled,
      'title': title,
      'message': message,
    };
  }
}

// Represents user-specific metadata for a notification, like read/deleted status.
class UserNotification {
  final int id; // Unique ID for this user-notification relationship
  bool deleted; // Whether the user has deleted this notification (mutable)
  final bool archived; // Whether the user has archived the notification
  final int userId; // The ID of the user
  final int notificationId; // Reference to the NotificationModel ID
  bool markRead; // Whether the user has read this notification (mutable)

  UserNotification({
    required this.id,
    required this.deleted,
    required this.archived,
    required this.userId,
    required this.notificationId,
    required this.markRead,
  });

  // Creates a UserNotification from a JSON map
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

  // Converts the UserNotification to a JSON map
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
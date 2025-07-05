class NotificationModel {
  final int notificationId;
  final bool active;
  // Changed from String to handle JSON translations
  final Map<String, dynamic> header;
  final Map<String, dynamic> content;

  NotificationModel({
    required this.notificationId,
    required this.active,
    required this.header,
    required this.content,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Helper function to handle conversion from String or Map to a Map
    Map<String, dynamic> parseTranslatableField(
        dynamic fieldData, String fallbackValue) {
      if (fieldData is Map<String, dynamic>) {
        return fieldData;
      }
      if (fieldData is String) {
        // If we receive an old string format, wrap it in a map as a fallback.
        return {'en': fieldData};
      }
      // Default fallback if data is null or unexpected type
      return {'en': fallbackValue};
    }

    return NotificationModel(
      notificationId: json['notificationId'],
      active: json['active'] ?? false,

      // Use the helper to parse header and content safely
      header: parseTranslatableField(json['header'], 'No Title'),
      content: parseTranslatableField(json['content'], 'No message content.'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'active': active,
      'header': header,
      'content': content,
    };
  }
}

class UserNotification {
  final int notificationUserid;
  bool deleted;
  final bool archived;
  final int userId;
  final int notificationId;
  bool markRead;

  UserNotification({
    required this.notificationUserid,
    required this.deleted,
    required this.archived,
    required this.userId,
    required this.notificationId,
    required this.markRead,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      notificationUserid: json['notificationUserId'],
      deleted: json['deleted'] ?? false,
      archived: json['archived'] ?? false,
      userId: json['userId'],
      notificationId: json['notificationId'],
      markRead: json['markRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationUserId': notificationUserid,
      'deleted': deleted,
      'archived': archived,
      'userId': userId,
      'notificationId': notificationId,
      'markRead': markRead,
    };
  }
}

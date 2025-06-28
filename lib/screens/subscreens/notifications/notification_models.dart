class NotificationModel {
  final int notificationId;
  final bool active;
  final String header; // Corresponds to 'title' in old model
  final String content; // Corresponds to 'message' in old model

  NotificationModel({
    required this.notificationId,
    required this.active,
    required this.header,
    required this.content,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'],

      // --- FIX 1: Map the new property 'active' to the 'active' key from JSON ---
      active: json['active'] ?? false,

      // --- FIX 2: Map 'header' and 'content' to their corresponding keys from JSON ---
      // Assuming your API now sends 'header' and 'content'.
      // If it still sends 'title' and 'message', map them accordingly like this:
      header: json['header'] ?? json['title'] ?? 'No Title',
      content: json['content'] ?? json['message'] ?? 'No message content.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // FIX 3: Use a consistent key name, likely camelCase for JSON conventions
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
      // FIX 4: Use the consistent key 'notificationUserId'
      'notificationUserId': notificationUserid,
      'deleted': deleted,
      'archived': archived,
      'userId': userId,
      'notificationId': notificationId,
      'markRead': markRead,
    };
  }
}

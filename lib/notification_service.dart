import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'notification_models.dart';

class NotificationService {
  /// Loads the user's notification metadata from a JSON file in assets.
  /// This includes things like read, deleted, and archived status.
  Future<List<UserNotification>> loadUserNotifications() async {
    try {
      print("Loading userNotifications.json...");
      final String response =
          await rootBundle.loadString('assets/json/userNotifications.json');
      print("Loaded userNotifications.json content: $response");

      // Parse JSON into a list of UserNotification objects
      final List<dynamic> data = json.decode(response);
      return data.map((jsonItem) => UserNotification.fromJson(jsonItem)).toList();
    } catch (e) {
      // Log any error encountered while loading/parsing
      print("Error parsing userNotifications.json: $e");
      rethrow; // Rethrow so calling functions can handle it
    }
  }

  /// Loads the general notification definitions from JSON in assets.
  /// Each notification contains a title, message, and other global properties.
  Future<List<NotificationModel>> loadNotifications() async {
    try {
      print("Loading notifications.json...");
      final String response =
          await rootBundle.loadString('assets/json/notifications.json');
      print("Loaded notifications.json content: $response");

      // Parse JSON into a list of NotificationModel objects
      final List<dynamic> data = json.decode(response);
      return data.map((jsonItem) => NotificationModel.fromJson(jsonItem)).toList();
    } catch (e) {
      // Log any error encountered while loading/parsing
      print("Error parsing notifications.json: $e");
      rethrow;
    }
  }

  /// Combines user-specific notification metadata with the actual notification content.
  /// Filters out deleted or disabled notifications for the given [userId].
  Future<List<Map<String, dynamic>>> getUserNotifications(int userId) async {
    // Load both notification data and user-specific metadata
    final notifications = await loadNotifications();
    final userNotifications = await loadUserNotifications();

    // Filter user notifications by userId and if not deleted
    final filteredUserNotifications =
        userNotifications.where((un) => un.userId == userId && !un.deleted).toList();

    List<Map<String, dynamic>> combinedList = [];

    // Match each user notification with the corresponding global notification
    for (var userNotif in filteredUserNotifications) {
      final notif = notifications.firstWhere(
        (n) => n.id == userNotif.notificationId,
        orElse: () => NotificationModel(
          id: -1,
          createdDt: DateTime.now(),
          enabled: false,
          title: '',
          message: '',
        ), // Provide fallback in case no match is found
      );

      // Add to final list only if the notification is valid and enabled
      if (notif.enabled && notif.id != -1) {
        combinedList.add({
          "userNotification": userNotif,
          "notification": notif,
        });
      }
    }

    return combinedList; // Final merged list of active, user-specific notifications
  }
}
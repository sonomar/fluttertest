import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'notification_models.dart';

class NotificationService {
  Future<List<UserNotification>> loadUserNotifications() async {
    try {
      print("Loading userNotifications.json...");
      final String response =
          await rootBundle.loadString('assets/json/userNotifications.json');
      print("Loaded userNotifications.json content: $response");

      final List<dynamic> data = json.decode(response);
      return data.map((jsonItem) => UserNotification.fromJson(jsonItem)).toList();
    } catch (e) {
      print("Error parsing userNotifications.json: $e");
      rethrow;
    }
  }

  Future<List<NotificationModel>> loadNotifications() async {
    try {
      print("Loading notifications.json...");
      final String response =
          await rootBundle.loadString('assets/json/notifications.json');
      print("Loaded notifications.json content: $response");

      final List<dynamic> data = json.decode(response);
      return data.map((jsonItem) => NotificationModel.fromJson(jsonItem)).toList();
    } catch (e) {
      print("Error parsing notifications.json: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(int userId) async {
    final notifications = await loadNotifications();
    final userNotifications = await loadUserNotifications();

    // Filter user notifications by userId and deleted flag
    final filteredUserNotifications =
        userNotifications.where((un) => un.userId == userId && !un.deleted).toList();

    List<Map<String, dynamic>> combinedList = [];
    for (var userNotif in filteredUserNotifications) {
      final notif = notifications.firstWhere(
        (n) => n.id == userNotif.notificationId,
        orElse: () => NotificationModel(
          id: -1,
          createdDt: DateTime.now(),
          enabled: false,
          title: '',
          message: '',
        ),
      );

      if (notif.enabled && notif.id != -1) {
        combinedList.add({
          "userNotification": userNotif,
          "notification": notif,
        });
      }
    }

    return combinedList;
  }
}
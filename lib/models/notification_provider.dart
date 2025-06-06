import 'package:flutter/material.dart';
import 'package:kloppocar_app/api/notification.dart';
import 'package:kloppocar_app/api/notification_user.dart';
import 'package:kloppocar_app/models/app_auth_provider.dart';
import 'package:kloppocar_app/models/user_model.dart';
import 'package:kloppocar_app/screens/subscreens/notifications/notification_models.dart';

class NotificationProvider with ChangeNotifier {
  final AppAuthProvider _appAuthProvider;
  final UserModel _userModel;

  List<Map<String, dynamic>> _notificationsWithDetails = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoadedOnce = false;

  NotificationProvider(this._appAuthProvider, this._userModel) {
    _userModel.addListener(_handleUserChange);
    if (_userModel.currentUser != null &&
        _userModel.currentUser?['userId'] != null) {
      loadUserNotifications();
    }
  }

  void _handleUserChange() {
    if (_userModel.currentUser != null &&
        _userModel.currentUser?['userId'] != null) {
      loadUserNotifications();
    } else {
      _notificationsWithDetails = [];
      _unreadNotificationCount = 0;
      _isLoading = false;
      _errorMessage = null;
      _hasLoadedOnce = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userModel.removeListener(_handleUserChange);
    super.dispose();
  }

  List<Map<String, dynamic>> get notificationsWithDetails =>
      _notificationsWithDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoadedOnce => _hasLoadedOnce;

  int _unreadNotificationCount = 0;
  int get unreadNotificationCount => _unreadNotificationCount;

  Future<void> loadUserNotifications() async {
    final String? userId = _userModel.currentUser?['userId']?.toString();
    if (userId == null) {
      _errorMessage = "User not logged in. Cannot load notifications.";
      _isLoading = false;
      _notificationsWithDetails = [];
      _unreadNotificationCount = 0;
      _hasLoadedOnce = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    if (!_hasLoadedOnce) {
      _errorMessage = null;
    }
    notifyListeners();

    try {
      final List<dynamic>? userNotificationsRaw =
          await getNotificationUsersByUserId(userId, _appAuthProvider);

      if (userNotificationsRaw == null) {
        _errorMessage =
            "Failed to fetch user notifications (API returned null).";
        _notificationsWithDetails = [];
        _unreadNotificationCount = 0;
        _isLoading = false;
        _hasLoadedOnce = true;
        notifyListeners();
        return;
      }
      List<Map<String, dynamic>> combinedList = [];
      int currentUnreadCount = 0;
      for (var userNotifRaw in userNotificationsRaw) {
        if (userNotifRaw is! Map<String, dynamic>) {
          continue;
        }
        final UserNotification userNotif =
            UserNotification.fromJson(userNotifRaw);
        if (userNotif.deleted) {
          continue;
        }

        // --- FIX 5: Corrected the function name from getNotificationByUserId to getNotificationByNotificationId ---
        final dynamic notificationTemplateRaw =
            await getNotificationByNotificationId(
                userNotif.notificationId.toString(), _appAuthProvider);

        if (notificationTemplateRaw != null &&
            notificationTemplateRaw is Map<String, dynamic>) {
          final NotificationModel notificationTemplate =
              NotificationModel.fromJson(notificationTemplateRaw);

          // --- FIX 6: Removed the confusing debug line ---
          // final enabled = notificationTemplate.content; // This line was removed

          if (notificationTemplate.active) {
            combinedList.add({
              "userNotification": userNotif,
              "notification": notificationTemplate,
            });
            if (!userNotif.markRead) {
              currentUnreadCount++;
            }
          }
        } else {
          print(
              "NotificationProvider: Could not fetch or parse notification template ID: ${userNotif.notificationId}");
        }
      }

      _notificationsWithDetails = combinedList;
      _unreadNotificationCount = currentUnreadCount;
      _errorMessage = null;
      print(
          "NotificationProvider: Loaded ${_notificationsWithDetails.length} notifications, $currentUnreadCount unread.");
    } catch (e, s) {
      _errorMessage = "Error loading notifications: ${e.toString()}";
      print("NotificationProvider: $_errorMessage Stack: $s");
      _notificationsWithDetails = [];
      _unreadNotificationCount = 0;
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  // --- The rest of the NotificationProvider methods (_updateUserNotificationStatus, etc.) ---
  // These should work correctly with the updated model property names.

  Future<bool> _updateUserNotificationStatus(
      int userNotificationId, Map<String, dynamic> updates) async {
    if (_appAuthProvider.status != AuthStatus.authenticated) {
      _errorMessage = "User not authenticated. Cannot update notification.";
      notifyListeners();
      return false;
    }

    try {
      Map<String, dynamic> bodyForApi = {
        "notificationUserId": userNotificationId,
        ...updates,
      };

      await updateNotificationUserByNotificationUserId(
          bodyForApi, _appAuthProvider);

      await loadUserNotifications();
      return true;
    } catch (e, s) {
      _errorMessage =
          "Failed to update notification (ID: $userNotificationId): ${e.toString()}";
      print("NotificationProvider: $_errorMessage Stack: $s");
      await loadUserNotifications();
      return false;
    }
  }

  Future<void> markNotificationAsRead(UserNotification userNotification) async {
    if (!userNotification.markRead) {
      print(
          "NotificationProvider: Marking notification ID ${userNotification.notificationUserid} as read.");
      await _updateUserNotificationStatus(
          userNotification.notificationUserid, {"markRead": true});
    }
  }

  Future<void> deleteUserNotification(UserNotification userNotification) async {
    print(
        "NotificationProvider: Deleting notification ID ${userNotification.notificationUserid}.");
    await _updateUserNotificationStatus(
        userNotification.notificationUserid, {"deleted": true});
  }
}

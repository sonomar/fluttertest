import 'package:flutter/material.dart';
import 'package:deins_app/api/notification.dart';
import 'package:deins_app/api/notification_user.dart';
import 'package:deins_app/api/user.dart' as api_user;
import 'package:deins_app/models/app_auth_provider.dart';
import 'package:deins_app/models/user_model.dart';
import 'package:deins_app/screens/subscreens/notifications/notification_models.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

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
      _initializePushNotifications(_userModel.currentUser!.userId);
    }
  }

  void _handleUserChange() {
    if (_userModel.currentUser != null &&
        _userModel.currentUser?['userId'] != null) {
      loadUserNotifications();
      _initializePushNotifications(_userModel.currentUser!.userId);
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
      _errorMessage = "Notification error: User not logged in";
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
        _errorMessage = "notifications api returned null";
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

  /// Initializes Firebase Cloud Messaging (FCM) by getting the device token
  /// and sending it to your backend for storage.
  /// This should be called once the user is authenticated and their ID is available.
  Future<void> _initializePushNotifications(String userId) async {
    try {
      // Get the current FCM token.
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print('FCM Token (from _initializePushNotifications): $fcmToken');

      // Compare with the token stored in the user model (if available)
      // or send if the user model doesn't have it yet.
      if (fcmToken != null &&
          _userModel.currentUser?.fcmDeviceToken != fcmToken) {
        print('FCM Token changed or not yet stored. Sending to backend.');
        // Send the FCM token to your backend using the API layer
        await registerFcmToken(
          userId,
          fcmToken,
          Platform.isAndroid ? 'android' : 'ios',
          _appAuthProvider, // Pass the provider for authentication headers
        );
        // Update the user model locally after successful update
        _userModel.currentUser?.fcmDeviceToken = fcmToken;
        _userModel
            .notifyListeners(); // Notify UserModel listeners about the change
      } else if (fcmToken == null) {
        print('FCM Token is null. Cannot send to backend.');
      } else {
        print(
            'FCM Token is already up-to-date in user model. No need to send.');
      }

      // Set up foreground message handling (optional, if you want to show in-app alerts)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification?.title} / ${message.notification?.body}');
          // You might want to show a local notification here using flutter_local_notifications
          // or update UI directly.
          // After receiving a foreground message, you might want to refresh the notification list
          loadUserNotifications();
        }
      });

      // Handle interaction when the app is opened from a terminated state by a notification
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          print('App opened from terminated state by a notification!');
          _handleNotificationData(message.data);
          loadUserNotifications(); // Refresh notifications after opening from terminated state
        }
      });

      // Handle interaction when the app is opened from a background state by a notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from background by a notification!');
        _handleNotificationData(message.data);
        loadUserNotifications(); // Refresh notifications after opening from background
      });
    } catch (e) {
      print('Error initializing push notifications: $e');
    }
  }

  /// This function is now only responsible for sending the token to the backend
  /// if it changes or needs to be refreshed. The initial registration is at sign-up.
  /// It calls the registerFcmToken from api/notification.dart.
  Future<void> _sendTokenToBackend(String userId, String token) async {
    try {
      await registerFcmToken(
        userId,
        token,
        Platform.isAndroid ? 'android' : 'ios',
        _appAuthProvider,
      );
      print('FCM token successfully sent to backend for user $userId via API.');
    } catch (e) {
      print('Error sending FCM token to backend via API: $e');
      // You might want to set an error message here if the API call fails
      // _errorMessage = "Failed to register push token: ${e.toString()}";
      // notifyListeners();
    }
  }

  /// Updates the user's preference for push notifications in the backend.
  /// This will update the 'push_notifications_enabled' column in the User table.
  Future<void> updatePushNotificationPreference(bool enabled) async {
    final String? userId = _userModel.currentUser?.userId?.toString();
    if (userId == null) {
      print(
          "Error: Cannot update push notification preference, user not logged in.");
      _errorMessage = "User not logged in to update push preference.";
      notifyListeners();
      return;
    }

    try {
      await api_user.updateUserByUserId(
        // Use existing updateUserByUserId
        {
          'userId': userId,
          'authData': {
            'pushEnabled': enabled ? '1' : '0' // Store as string '1' or '0'
          }
        },
        _appAuthProvider,
      );
      // Update the local user model after successful API call
      if (_userModel.currentUser != null) {
        if (_userModel.currentUser!.authData == null) {
          _userModel.currentUser!.authData = {};
        }
        _userModel.currentUser!.authData!['pushEnabled'] = enabled ? '1' : '0';
        _userModel
            .notifyListeners(); // Notify UserModel listeners about the change
      }
      print(
          "Push notification preference updated to: $enabled for user $userId");
      notifyListeners(); // Notify NotificationProvider listeners about potential error message clear
    } catch (e) {
      print("Error updating push notification preference: $e");
      _errorMessage =
          "Failed to update push notification preference: ${e.toString()}";
      notifyListeners();
    }
  }

  /// Example function to handle navigation or logic based on notification data.
  /// This can be expanded to navigate to specific screens based on notification content.
  void _handleNotificationData(Map<String, dynamic> data) {
    if (data.containsKey('notification_id')) {
      final notificationId = data['notification_id'];
      print('Handling notification data for ID: $notificationId');
      // In a real app, you might use a Navigator key or a routing service
      // to navigate to a specific screen here.
      // Example:
      // if (MyApp.navigatorKey.currentState != null) {
      //   MyApp.navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => NotificationDetailScreen(notificationId: notificationId)));
      // }
    }
    // Implement logic to handle other custom data from your push notifications.
  }

  Future<bool> _updateUserNotificationStatus(
      int userNotificationId, Map<String, dynamic> updates) async {
    if (_appAuthProvider.status != AuthStatus.authenticated) {
      _errorMessage = "No authProvider found to update UserNotification status";
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

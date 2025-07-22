import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'package:provider/provider.dart'; // For accessing NotificationProvider
import '../../helpers/localization_helper.dart'; // Adjust import path if your AppLocalizations is elsewhere
import '../../models/notification_provider.dart'; // Import NotificationProvider
import '../../models/user_model.dart'; // Import UserModel to get current user's push preference

/// A StatefulWidget that provides a switch to enable/disable camera access
/// for the application, handling permission requests and user guidance.
class CameraPermissionSwitch extends StatefulWidget {
  const CameraPermissionSwitch({super.key});

  @override
  State<CameraPermissionSwitch> createState() => _CameraPermissionSwitchState();
}

class _CameraPermissionSwitchState extends State<CameraPermissionSwitch> {
  bool _cameraPermissionGranted =
      false; // State to hold camera permission status

  @override
  void initState() {
    super.initState();
    _checkCameraPermissionStatus(); // Check permission status when the widget initializes
  }

  /// Checks the current camera permission status and updates the UI.
  Future<void> _checkCameraPermissionStatus() async {
    final status = await Permission.camera.status;
    if (mounted) {
      // Ensure the widget is still mounted before calling setState
      setState(() {
        _cameraPermissionGranted = status.isGranted;
      });
    }
  }

  /// Handles the toggling of the camera permission switch.
  /// Requests permission if enabling, or guides user to settings if disabling.
  Future<void> _toggleCameraPermission(bool newValue) async {
    if (newValue) {
      // User wants to enable camera
      final status = await Permission.camera.request(); // Request permission
      if (mounted) {
        if (status.isGranted) {
          setState(() {
            _cameraPermissionGranted = true;
          });
          _showSnackBar(translate('camera_enabled_message', context) ??
              'Camera access enabled.');
        } else if (status.isDenied) {
          setState(() {
            _cameraPermissionGranted = false; // Reset switch if denied
          });
          _showPermissionDeniedDialog(
            translate('camera_access_denied_title', context) ??
                'Camera Access Denied',
            translate('camera_access_denied_message_request', context) ??
                'You denied camera access. Please enable it in your device settings to use camera features.',
          );
        } else if (status.isPermanentlyDenied) {
          setState(() {
            _cameraPermissionGranted =
                false; // Reset switch if permanently denied
          });
          _showPermissionDeniedDialog(
            translate('camera_access_permanently_denied_title', context) ??
                'Camera Access Permanently Denied',
            translate('camera_access_permanently_denied_message', context) ??
                'Camera access is permanently denied. Please go to app settings to enable it.',
          );
        } else if (status.isRestricted) {
          // e.g., parental controls
          setState(() {
            _cameraPermissionGranted = false; // Reset switch if restricted
          });
          _showSnackBar(
              translate('camera_access_restricted_message', context) ??
                  'Camera access is restricted by device policy.');
        }
      }
    } else {
      // User wants to disable camera
      if (mounted) {
        setState(() {
          // Optimistically set false, but actual change requires user action
          _cameraPermissionGranted = false;
        });
      }
      _showDisablePermissionDialog(
        translate('disable_camera_title', context) ?? 'Disable Camera Access',
        translate('disable_camera_message', context) ??
            'To disable camera access, please go to your device settings.',
      );
    }
  }

  /// Shows a brief message at the bottom of the screen.
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Shows a dialog when permission is denied, offering to open app settings.
  void _showPermissionDeniedDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(translate('cancel_button', context) ?? 'Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _checkCameraPermissionStatus(); // Re-check status to sync switch
              },
            ),
            TextButton(
              child: Text(translate('open_settings_button', context) ??
                  'Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // Opens the app's settings page
                // It's good practice to re-check status after user might return from settings
                Future.delayed(
                    const Duration(seconds: 1), _checkCameraPermissionStatus);
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog when the user attempts to disable a permission,
  /// explaining it must be done in device settings.
  void _showDisablePermissionDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(translate('got_it_button', context) ?? 'Got It'),
              onPressed: () {
                Navigator.of(context).pop();
                _checkCameraPermissionStatus(); // Re-check status to sync switch
              },
            ),
            TextButton(
              child: Text(translate('open_settings_button', context) ??
                  'Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
                Future.delayed(
                    const Duration(seconds: 1), _checkCameraPermissionStatus);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title:
          Text(translate('camera_access_setting', context) ?? 'Camera Access'),
      subtitle: Text(translate('camera_access_description', context) ??
          'Allow this app to use your device\'s camera for scanning features.'),
      value: _cameraPermissionGranted,
      onChanged: _toggleCameraPermission,
    );
  }
}

/// A StatefulWidget that provides a switch to enable/disable push notification access
/// for the application, handling permission requests and user guidance.
class PushNotificationPermissionSwitch extends StatefulWidget {
  const PushNotificationPermissionSwitch({super.key});

  @override
  State<PushNotificationPermissionSwitch> createState() =>
      _PushNotificationPermissionSwitchState();
}

class _PushNotificationPermissionSwitchState
    extends State<PushNotificationPermissionSwitch> {
  bool _pushNotificationPermissionGranted =
      false; // State to hold notification system permission status
  bool _userPreferenceEnabled =
      false; // State to hold user's preference from backend (authData.pushEnabled)

  @override
  void initState() {
    super.initState();
    _checkPushNotificationPermissionStatus();
    // Listen to UserModel changes to update user preference from backend
    context.read<UserModel>().addListener(_updateUserPreferenceFromModel);
  }

  @override
  void dispose() {
    context.read<UserModel>().removeListener(_updateUserPreferenceFromModel);
    super.dispose();
  }

  /// Updates the local _userPreferenceEnabled state based on the UserModel's authData.pushEnabled.
  void _updateUserPreferenceFromModel() {
    final userModel = context.read<UserModel>();
    if (userModel.currentUser != null && mounted) {
      setState(() {
        // Read 'pushEnabled' from authData, default to '0' if null or not present
        _userPreferenceEnabled =
            userModel.currentUser!.authData?['pushEnabled'] == '1';
      });
    }
  }

  /// Checks the current push notification permission status and updates the UI.
  Future<void> _checkPushNotificationPermissionStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final userModel = context.read<UserModel>();

    if (mounted) {
      setState(() {
        // System-level permission status
        _pushNotificationPermissionGranted =
            settings.authorizationStatus == AuthorizationStatus.authorized ||
                settings.authorizationStatus == AuthorizationStatus.provisional;
        // User preference from backend
        _userPreferenceEnabled =
            userModel.currentUser?.authData?['pushEnabled'] == '1';
      });
    }
  }

  /// Handles the toggling of the push notification permission switch.
  Future<void> _togglePushNotificationPermission(bool newValue) async {
    final notificationProvider = context.read<NotificationProvider>();
    // final userModel = context.read<UserModel>(); // Not directly used here, preference updated via provider

    if (newValue) {
      // User wants to enable push notifications
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (mounted) {
        if (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional) {
          setState(() {
            _pushNotificationPermissionGranted = true;
            _userPreferenceEnabled =
                true; // Optimistically update UI based on user action
          });
          _showSnackBar(translate('push_enabled_message', context) ??
              'Push notifications enabled.');
          await notificationProvider
              .updatePushNotificationPreference(true); // Update backend
        } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
          setState(() {
            _pushNotificationPermissionGranted = false;
            _userPreferenceEnabled =
                false; // Reset UI as system permission is denied
          });
          _showPermissionDeniedDialog(
            translate('push_access_denied_title', context) ??
                'Notification Access Denied',
            translate('push_access_denied_message_request', context) ??
                'You denied notification access. Please enable it in your device settings to receive push notifications.',
          );
        } else if (settings.authorizationStatus ==
            AuthorizationStatus.notDetermined) {
          setState(() {
            _pushNotificationPermissionGranted = false;
            _userPreferenceEnabled = false;
          });
          _showSnackBar(translate('push_not_determined_message', context) ??
              'Notification permission not determined.');
        }
      }
    } else {
      // User wants to disable push notifications
      if (mounted) {
        setState(() {
          _userPreferenceEnabled = false; // Optimistically update UI
        });
      }
      _showDisablePermissionDialog(
        translate('disable_push_title', context) ??
            'Disable Push Notifications',
        translate('disable_push_message', context) ??
            'To fully disable push notifications, you may also need to go to your device settings.',
      );
      await notificationProvider
          .updatePushNotificationPreference(false); // Update backend
    }
    // Re-check status after potential changes (both system and backend preference)
    _checkPushNotificationPermissionStatus();
  }

  /// Shows a brief message at the bottom of the screen.
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Shows a dialog when permission is denied, offering to open app settings.
  void _showPermissionDeniedDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(translate('cancel_button', context) ?? 'Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _checkPushNotificationPermissionStatus(); // Re-check status to sync switch
              },
            ),
            TextButton(
              child: Text(translate('open_settings_button', context) ??
                  'Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // Opens the app's settings page
                Future.delayed(const Duration(seconds: 1),
                    _checkPushNotificationPermissionStatus);
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog when the user attempts to disable a permission,
  /// explaining it must be done in device settings.
  void _showDisablePermissionDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(translate('got_it_button', context) ?? 'Got It'),
              onPressed: () {
                Navigator.of(context).pop();
                _checkPushNotificationPermissionStatus(); // Re-check status to sync switch
              },
            ),
            TextButton(
              child: Text(translate('open_settings_button', context) ??
                  'Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
                Future.delayed(const Duration(seconds: 1),
                    _checkPushNotificationPermissionStatus);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // The switch's value should reflect the user's preference from the backend,
    // but also consider the system-level permission. If system permission is denied,
    // the switch should appear off, regardless of backend preference.
    final bool displayValue =
        _userPreferenceEnabled && _pushNotificationPermissionGranted;

    return SwitchListTile(
      title: Text(translate('push_notifications_setting', context) ??
          'Push Notifications'),
      subtitle: Text(translate('push_notifications_description', context) ??
          'Receive important updates and alerts from the app.'),
      value: displayValue,
      onChanged: _togglePushNotificationPermission,
    );
  }
}

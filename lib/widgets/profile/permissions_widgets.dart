// lib/widgets/profile/permissions_widgets.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../helpers/localization_helper.dart'; // Adjust import path if your AppLocalizations is elsewhere

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
      _showDisableCameraDialog(
        translate('disable_camera_title', context) ?? 'Disable Camera Access',
        translate('disable_camera_message', context) ??
            'To disable camera access, you must go to your device\'s app settings.',
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
  void _showDisableCameraDialog(String title, String message) {
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

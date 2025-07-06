import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../helpers/localization_helper.dart';
import 'package:deins_app/models/notification_provider.dart';
import 'package:deins_app/screens/subscreens/notifications/notification_models.dart';

class NotificationDetailPage extends StatefulWidget {
  final UserNotification userNotification; // Receive UserNotification object
  final NotificationModel notification; // Receive NotificationModel object

  const NotificationDetailPage({
    super.key,
    required this.userNotification,
    required this.notification,
  });

  @override
  _NotificationDetailPageState createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  late UserNotification
      _currentUserNotification; // To hold mutable state if needed

  @override
  void initState() {
    super.initState();
    _currentUserNotification =
        widget.userNotification; // Initialize with passed data

    // Mark as read if not already
    if (!_currentUserNotification.markRead) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<NotificationProvider>(context, listen: false)
            .markNotificationAsRead(_currentUserNotification);
        // Optimistically update local state for immediate UI feedback, provider will reload anyway
        if (mounted) {
          setState(() {
            _currentUserNotification.markRead = true;
          });
        }
      });
    }
  }

  Future<void> _deleteNotification() async {
    await Provider.of<NotificationProvider>(context, listen: false)
        .deleteUserNotification(_currentUserNotification);
    // After deleting, pop the page. The list on NotificationsPage will update
    // because deleteUserNotification triggers a reload in the provider.
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final userNotif = _currentUserNotification; // Use local state for display if optimistically updated
    final userNotif = widget
        .userNotification; // Or always use widget data if provider reloads fast
    final notif = widget.notification;

    return Scaffold(
      appBar: AppBar(
        title: Text(notif.header.isNotEmpty
            ? getTranslatedString(context, notif.header)
            : translate("notification_detail_build_default_title", context)),
        leading: IconButton(
          // Add back button
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getTranslatedString(context, notif.header),
              style: const TextStyle(
                fontSize: 22, // Increased size
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  getTranslatedString(context, notif.content),
                  style: const TextStyle(
                      fontSize: 16, height: 1.5), // Added line height
                ),
              ),
            ),
            const SizedBox(height: 20), // Space before buttons
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align buttons to the end
              children: [
                TextButton.icon(
                  // Use TextButton for less emphasis
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(
                      translate(
                          "account_settings_delete_dialog_delete", context),
                      style: TextStyle(color: Colors.red)),
                  onPressed: _deleteNotification,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                // Removed the "Back" button as AppBar has one.
                // If you need another primary action, replace this.
              ],
            ),
          ],
        ),
      ),
    );
  }
}

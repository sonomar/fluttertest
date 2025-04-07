import 'package:flutter/material.dart';
import 'notification_models.dart';

/// Page to show full details of a single notification.
class NotificationDetailPage extends StatefulWidget {
  final UserNotification userNotification;
  final NotificationModel notification;

  const NotificationDetailPage({
    super.key,
    required this.userNotification,
    required this.notification,
  });

  @override
  // ignore: library_private_types_in_public_api
  _NotificationDetailPageState createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  @override
  void initState() {
    super.initState();
    // Mark the notification as read if not already
    if (!widget.userNotification.markRead) {
      setState(() {
        widget.userNotification.markRead = true;
      });
      // save this change via an API or database.
    }
  }

  @override
  Widget build(BuildContext context) {
    final userNotif = widget.userNotification;
    final notif = widget.notification;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Notification title
            Text(
              notif.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Full message inside a scrollable view
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  notif.message,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            // Action buttons: Delete or Back
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  onPressed: () {
                    // Mark as deleted and go back
                    setState(() {
                      userNotif.deleted = true;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  onPressed: () {
                    // Just navigate back without any change
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
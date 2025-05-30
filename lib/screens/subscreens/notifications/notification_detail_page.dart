import 'package:flutter/material.dart';
import 'notification_models.dart';

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
    // Mark notification as read if it isn't already
    if (!widget.userNotification.markRead) {
      setState(() {
        widget.userNotification.markRead = true;
      });
      // In a real app, you'd also persist this state (e.g., via an API call or local DB).
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
            Text(
              notif.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  notif.message,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  onPressed: () {
                    // Set deleted = true and then navigate back.
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
                    // Just go back without deleting
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

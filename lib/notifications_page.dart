import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'notification_models.dart';
import 'notification_detail_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();

  // Future that holds the loaded user notifications
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    // Load user notifications on screen init (userId = 1 for example)
    _notificationsFuture = _notificationService.getUserNotifications(1);
  }

  // Utility to show a short preview of the message (first 30 characters)
  String _shortPreview(String message) {
    return message.length <= 30 ? message : '${message.substring(0, 30)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set a white background for the entire page
      backgroundColor: Colors.white,

      // App bar with black icons and text, no elevation for clean look
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Notifications',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // Use a FutureBuilder to render async data (notifications)
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          // While waiting, show a loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If there's an error loading the data
          else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            );
          }

          // If there are no notifications
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No notifications',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            );
          }

          // Notifications exist, so display them in a ListView
          final notificationsData = snapshot.data!;

          return ListView.builder(
            itemCount: notificationsData.length,
            itemBuilder: (context, index) {
              // Extract the models from the combined notification map
              final userNotif = notificationsData[index]['userNotification']
                  as UserNotification;
              final notif =
                  notificationsData[index]['notification'] as NotificationModel;

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  // Notification title, bold if unread
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight: userNotif.markRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  // Short preview of the message body
                  subtitle: Text(_shortPreview(notif.message)),
                  onTap: () async {
                    // Open the detailed view for the tapped notification
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NotificationDetailPage(
                          userNotification: userNotif,
                          notification: notif,
                        ),
                      ),
                    );

                    // Refresh the state on return to show updated read status
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
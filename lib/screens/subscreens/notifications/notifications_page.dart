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
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationService.getUserNotifications(1);
  }

  // Helper to get the first 30 chars of a message
  String _shortPreview(String message) {
    return message.length <= 30 ? message : '${message.substring(0, 30)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Standard white background
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white, // White AppBar background
        elevation: 0, // No shadow
        title: const Text(
          'My Notifications',
          style: TextStyle(color: Colors.black), // Black text for the title
        ),
        iconTheme: const IconThemeData(color: Colors.black), // Black icons
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(
                    color: Colors.black, fontSize: 16), // Black text
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No notifications',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            );
          }

          final notificationsData = snapshot.data!;

          return ListView.builder(
            itemCount: notificationsData.length,
            itemBuilder: (context, index) {
              final userNotif = notificationsData[index]['userNotification']
                  as UserNotification;
              final notif =
                  notificationsData[index]['notification'] as NotificationModel;

              return Card(
                color: Colors.white, // Pure white card background
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight: userNotif.markRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(_shortPreview(notif.message)),
                  onTap: () async {
                    // Navigate to Notification Detail Page
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NotificationDetailPage(
                          userNotification: userNotif,
                          notification: notif,
                        ),
                      ),
                    );
                    setState(() {}); // Refresh list after returning
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

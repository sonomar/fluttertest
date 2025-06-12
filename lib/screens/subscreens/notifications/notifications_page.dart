import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../helpers/localization_helper.dart';
import 'package:kloppocar_app/models/notification_provider.dart';
import 'package:kloppocar_app/screens/subscreens/notifications/notification_models.dart';
import 'package:kloppocar_app/screens/subscreens/notifications/notification_detail_page.dart';
// Removed: import 'notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
  }

  String _shortPreview(String message) {
    return message.length <= 30 ? message : '${message.substring(0, 30)}...';
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer for reacting to loading states and data changes
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        Widget body;
        if (provider.isLoading && !provider.hasLoadedOnce) {
          // Show loader on first load attempt
          body = const Center(child: CircularProgressIndicator());
        } else if (provider.errorMessage != null &&
            provider.notificationsWithDetails.isEmpty) {
          body = Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${provider.errorMessage}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (provider.notificationsWithDetails.isEmpty) {
          body = Center(
            child: Text(
              translate("notifications_none", context),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          );
        } else {
          final notificationsData = provider.notificationsWithDetails;
          body = RefreshIndicator(
            onRefresh: () => provider.loadUserNotifications(),
            child: ListView.builder(
              itemCount: notificationsData.length,
              itemBuilder: (context, index) {
                final userNotif = notificationsData[index]['userNotification']
                    as UserNotification;
                final notif = notificationsData[index]['notification']
                    as NotificationModel;

                return Card(
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      notif.header,
                      style: TextStyle(
                        fontWeight: userNotif.markRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(_shortPreview(notif.content)),
                    trailing: userNotif.markRead
                        ? null
                        : Icon(Icons.circle,
                            color: Theme.of(context).primaryColor, size: 12),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NotificationDetailPage(
                            userNotification:
                                userNotif, // Pass the UserNotification object
                            notification:
                                notif, // Pass the NotificationModel object
                          ),
                        ),
                      );
                      // No explicit setState needed here as provider changes will trigger rebuild if necessary,
                      // or NotificationDetailPage handles updates and pops.
                      // If detail page updates state that list page needs, provider should handle it.
                    },
                  ),
                );
              },
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            scrolledUnderElevation: 0.0,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              translate("notifications_header", context),
              style: TextStyle(color: Colors.black),
            ),
            leading: IconButton(
              // Add back button
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: body,
        );
      },
    );
  }
}

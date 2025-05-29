import 'api_init.dart';

Future<dynamic> getNotificationUsersByUserId(id) async {
  final res = apiGetRequest(
      'NotificationUser/getNotificationUsersByUserId', {"UserId": id});
  if (res != null) {
    return res;
  } else {
    throw 'database GET error';
  }
}

Future<dynamic> updateNotificationUserByNotificationUserId(notificationUserId,
    {notificationId,
    userId,
    markedRead,
    archived,
    deleted,
    pushNotification}) async {
  final res = apiPatchRequest(
      'NotificationUser/updateNotificationUserByNotificationUserId', {
    "notificationUserId": notificationUserId,
    "notificationId": notificationId,
    "userId": userId,
    "markedRead": markedRead,
    "archived": archived,
    "deleted": deleted,
    "pushNotification": pushNotification,
  });
  if (res != null) {
    return res;
  } else {
    throw ' database PATCH error';
  }
}

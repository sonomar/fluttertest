import 'api_init.dart';

Future<dynamic> getNotificationByNotificationId(id) async {
  final res = apiGetRequest(
      'Notification/getNotificationByNotificationId', {"notificationId": id});
  if (res != null) {
    return res;
  } else {
    throw 'database GET error';
  }
}

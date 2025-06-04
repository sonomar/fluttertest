import 'api_init.dart';

Future<dynamic> getNotificationByNotificationId(id, provider) async {
  final res = apiGetRequest('Notification/getNotificationByNotificationId',
      {"notificationId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw 'database GET error';
  }
}

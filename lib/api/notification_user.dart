import 'api_init.dart';

Future<dynamic> getNotificationUsersByUserId(id, provider) async {
  final res = apiGetRequest('NotificationUser/getNotificationUsersByUserId',
      {"userId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw 'database GET error';
  }
}

Future<dynamic> updateNotificationUserByNotificationUserId(
    body, provider) async {
  final res = apiPatchRequest(
      'NotificationUser/updateNotificationUserByNotificationUserId',
      body,
      provider);
  if (res != null) {
    return res;
  } else {
    throw ' database PATCH error';
  }
}

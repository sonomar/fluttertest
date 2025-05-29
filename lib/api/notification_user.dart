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

Future<dynamic> updateNotificationUserByNotificationUserId(body) async {
  final res = apiPatchRequest(
      'NotificationUser/updateNotificationUserByNotificationUserId', body);
  if (res != null) {
    return res;
  } else {
    throw ' database PATCH error';
  }
}

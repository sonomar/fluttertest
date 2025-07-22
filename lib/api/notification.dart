import 'api_init.dart';

Future<dynamic> getNotificationByUserId(id, provider) async {
  final res = apiGetRequest(
      'Notification/getNotificationByUserId', {"userId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw 'database GET error';
  }
}

Future<dynamic> getNotificationByNotificationId(id, provider) async {
  final res = apiGetRequest('Notification/getNotificationByNotificationId',
      {"notificationId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw 'database GET error';
  }
}

/// This function uses the generic apiPostRequest from api_init.dart.
Future<dynamic> registerFcmToken(
    String userId, String fcmToken, String platform, dynamic provider) async {
  final Map<String, dynamic> body = {
    'user_id': userId,
    'fcm_device_token': fcmToken,
    'platform': platform,
  };
  // Assuming your backend endpoint for token registration is under the 'User' table
  // and the specific path is 'registerFcmToken'. Adjust if your API Gateway path differs.
  final res = await apiPostRequest(
      'User/registerFcmToken', // Example path: /User/registerFcmToken
      body,
      provider);
  if (res != null) {
    return res;
  } else {
    // Provide a more specific error message if possible
    throw 'Failed to register FCM token via API';
  }
}

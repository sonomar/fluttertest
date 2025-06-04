import 'api_init.dart';

Future<dynamic> getUserByEmail(email, provider) async {
  print('API: getUserByEmail START for $email at ${DateTime.now()}');
  final res = apiGetRequest('User/getUserByEmail', {"email": email}, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> updateUserByUserId(body, provider) async {
  final res = apiPatchRequest('User/updateUserByUserId', body, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database PATCH error';
  }
}

Future<dynamic> createUser(
    email, password, userType, username, deviceId, provider) async {
  final res = apiPostRequest(
      'User/createUser',
      {
        "email": email,
        "passwordHashed": password,
        "userType": userType,
        "username": username,
        "deviceId": deviceId
      },
      provider);
  if (res != null) {
    return res;
  } else {
    throw ' database POST error';
  }
}

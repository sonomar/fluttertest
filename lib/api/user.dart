import 'api_init.dart';

Future<dynamic> getUserByEmail(email) async {
  final res = apiGetRequest('User/getUserByEmail', {"email": email});
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> updateUserByUserId(body) async {
  final res = apiPatchRequest('User/updateUserByUserId', body);
  if (res != null) {
    return res;
  } else {
    throw ' database PATCH error';
  }
}

Future<dynamic> createUser(
    email, password, userType, username, deviceId) async {
  final res = apiPostRequest('User/createUser', {
    "email": email,
    "passwordHashed": password,
    "userType": userType,
    "username": username,
    "deviceId": deviceId
  });
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

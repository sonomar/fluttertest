import 'api_init.dart';

Future<dynamic> getUserByEmail(email) async {
  final res = apiGetRequest('User/getUserByEmail', {"email": email});
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

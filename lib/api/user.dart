import 'api_init.dart';

void getUserByUserId(id, params) async {
  apiPatchRequest('/getUserByUserId', params);
}

void updateUserByUserId(id, params) async {
  apiPatchRequest('/updateUserByUserId', params);
}

import 'api_init.dart';

void updateUserByUserId(id, username) async {
  apiPatchRequest('/updateUserByUserId', {"UserId": 2, 'username': 'testman'});
}

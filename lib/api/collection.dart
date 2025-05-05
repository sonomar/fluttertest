import 'api_init.dart';

void getAllCollectibles() async {
  apiGetRequest('/getAllCollectibles', {});
}

void getCollectibleByCollectibleId(id) async {
  apiGetRequest('/getCollectibleByCollectibleId', {"CollectibleId": id});
}

void updateUserByUserId(id, username) async {
  apiPatchRequest('/updateUserByUserId', {"UserId": 2, 'username': 'testman'});
}

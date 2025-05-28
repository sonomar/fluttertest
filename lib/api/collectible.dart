import 'api_init.dart';

void getAllCollectibles() async {
  apiGetRequest('Collectible/getAllCollectibles', {});
}

void getCollectibleByCollectibleId(id) async {
  apiGetRequest(
      'Collectible/getCollectibleByCollectibleId', {"CollectibleId": id});
}

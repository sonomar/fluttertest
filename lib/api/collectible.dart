import 'api_init.dart';

Future<List> getAllCollectibles() async {
  final res = await apiGetRequest('Collectible/getAllCollectibles', {});
  if (res != null) {
    return res;
  } else {
    throw 'database GET error';
  }
}

Future<List> getCollectibleByCollectibleId(id) async {
  final res = await apiGetRequest(
      'Collectible/getCollectibleByCollectibleId', {"CollectibleId": id});
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<List> getCollectiblesByCollectionId(id) async {
  final res = await apiGetRequest(
      'Collectible/getCollectiblesByCollectionId', {"CollectionId": id});
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

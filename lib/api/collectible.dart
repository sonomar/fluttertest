import 'api_init.dart';

Future<dynamic> getAllCollectibles() async {
  final res = apiGetRequest('Collectible/getAllCollectibles', {});
  if (res != null) {
    return res;
  } else {
    throw 'database GET error';
  }
}

Future<dynamic> getCollectibleByCollectibleId(id) async {
  final res = apiGetRequest(
      'Collectible/getCollectibleByCollectibleId', {"collectibleId": id});
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> getCollectiblesByCollectionId(id) async {
  final res = apiGetRequest(
      'Collectible/getCollectiblesByCollection', {"collectionId": id});
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> updateCollectibleByCollectibleId(body) async {
  final res =
      apiPatchRequest('Collectible/updateCollectibleByCollectibleId', body);
  if (res != null) {
    return res;
  } else {
    throw ' database PATCH error';
  }
}

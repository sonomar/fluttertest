import 'api_init.dart';

Future<dynamic> getAllCollectibles(provider) async {
  final res = apiGetRequest('Collectible/getAllCollectibles', {}, provider);
  if (res != null) {
    return res;
  } else {
    throw 'database GET error';
  }
}

Future<dynamic> getCollectibleByCollectibleId(id, provider) async {
  final res = apiGetRequest('Collectible/getCollectibleByCollectibleId',
      {"collectibleId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> getCollectiblesByCollectionId(id, provider) async {
  final res = apiGetRequest('Collectible/getCollectiblesByCollection',
      {"collectionId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> updateCollectibleByCollectibleId(body, provider) async {
  final res = apiPatchRequest(
      'Collectible/updateCollectibleByCollectibleId', body, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database PATCH error';
  }
}

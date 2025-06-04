import 'api_init.dart';

Future<dynamic> getUserCollectiblesByOwnerId(id, provider) async {
  final res = apiGetRequest('UserCollectible/getUserCollectiblesByOwnerId',
      {"ownerId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> createUserCollectible(
    userId, collectibleId, mint, provider) async {
  final res = apiPostRequest(
      'UserCollectible/createUserCollectible',
      {
        "ownerId": userId,
        "collectibleId": collectibleId,
        "mint": mint,
      },
      provider);
  if (res != null) {
    return res;
  } else {
    throw ' database POST error';
  }
}

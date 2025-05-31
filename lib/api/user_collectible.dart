import 'api_init.dart';

Future<dynamic> getUserCollectiblesByOwnerId(id) async {
  final res = apiGetRequest(
      'UserCollectible/getUserCollectiblesByOwnerId', {"ownerId": id});
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> createUserCollectible(userId, collectibleId, mint) async {
  final res = apiPostRequest('UserCollectible/createUserCollectible', {
    "userId": userId,
    "collectibleId": collectibleId,
    "mint": mint,
  });
  if (res != null) {
    return res;
  } else {
    throw ' database POST error';
  }
}

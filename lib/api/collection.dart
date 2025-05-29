import 'api_init.dart';

Future<dynamic> getCollectionByCollectionId(id) async {
  final res = apiGetRequest(
      'Collection/getCollectionByCollectionId', {"collectionId": id});
  if (res != null) {
    return res;
  } else {
    throw 'database GET error';
  }
}

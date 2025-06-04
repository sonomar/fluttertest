import 'api_init.dart';

Future<dynamic> getCollectionByCollectionId(id, provider) async {
  final res = apiGetRequest(
      'Collection/getCollectionByCollectionId', {"collectionId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw 'database GET error';
  }
}

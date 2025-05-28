import 'api_init.dart';

Future<List> getCollectionByCollectionId(id) async {
  final res = await apiGetRequest(
      'Collection/getCollectionByCollectionId', {"CollectionId": id});
  if (res != null) {
    return res;
  } else {
    throw 'database GET error';
  }
}

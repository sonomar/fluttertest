import 'api_init.dart';

Future<dynamic> getNewsPostByNewsPostId(id, provider) async {
  final res = apiGetRequest(
      'NewsPost/getNewsPostByNewsPostId', {"newsPostId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

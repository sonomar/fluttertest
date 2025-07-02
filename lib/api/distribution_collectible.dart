import 'api_init.dart';

Future<dynamic> getDistributionCollectibleByDistributionCollectibleId(
    id, provider) async {
  final res = apiGetRequest(
      'DistributionCollectible/getDistributionCollectibleByDistributionCollectibleId',
      {"distributionCollectibleId": id},
      provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> getDistributionCollectiblesByDistributionId(
    id, provider) async {
  final res = apiGetRequest(
      'DistributionCollectible/getDistributionCollectiblesByDistributionId',
      {"distributionId": id},
      provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

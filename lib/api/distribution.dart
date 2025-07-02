import 'api_init.dart';

Future<dynamic> getDistributionByDistributionId(id, provider) async {
  final res = apiGetRequest('Distribution/getDistributionByDistributionId',
      {"distributionId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> createDistribution(body, provider) async {
  final res = apiPostRequest('Distribution/createDistribution', body, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database POST error';
  }
}

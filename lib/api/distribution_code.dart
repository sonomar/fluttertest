import 'api_init.dart';

Future<dynamic> getDistributionCodeByDistributionCodeId(id, provider) async {
  final res = apiGetRequest(
      'DistributionCode/getDistributionCodeByDistributionCodeId',
      {"distributionCodeId": id},
      provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> getDistributionCodeByCode(code, provider) async {
  final res = apiGetRequest(
      'DistributionCode/getDistributionCodeByCode', {"code": code}, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> createDistributionCode(body, provider) async {
  final res =
      apiPostRequest('DistributionCode/createDistributionCode', body, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database POST error';
  }
}

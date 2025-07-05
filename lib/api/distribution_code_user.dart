import 'api_init.dart';

Future<dynamic> getDistributionCodeUserByDistributionCodeUserId(
    id, provider) async {
  final res = apiGetRequest(
      'DistributionCodeUser/getDistributionCodeUserByDistributionCodeUserId',
      {"distributionCodeUserId": id},
      provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> getDistributionCodeUsersByUserId(id, provider) async {
  final res = apiGetRequest(
      'DistributionCodeUser/getDistributionCodeUsersByUserId',
      {"userId": id},
      provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> getDistributionCodeUsersByDistributionCodeId(
    id, provider) async {
  final res = apiGetRequest(
      'DistributionCodeUser/getDistributionCodeUsersByDistributionCodeId',
      {"distributionCodeId": id},
      provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> updateDistributionCodeUserByDistributionCodeUserId(
    body, provider) async {
  final res = apiPatchRequest(
      'DistributionCodeUser/updateDistributionCodeUserByDistributionCodeUserId',
      body,
      provider);
  if (res != null) {
    return res;
  } else {
    throw ' database POST error';
  }
}

Future<dynamic> createDistributionCodeUser(body, provider) async {
  final res = apiPostRequest(
      'DistributionCodeUser/createDistributionCodeUser', body, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database POST error';
  }
}

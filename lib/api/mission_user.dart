import 'api_init.dart';

Future<dynamic> getMissionUsersByChallengeId(id, provider) async {
  final res = apiGetRequest(
      'MissionUser/getMissionUsersByChallengeId', {"missionId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> getMissionUsersByUserId(id, provider) async {
  final res = apiGetRequest(
      'MissionUser/getMissionUsersByUserId', {"userId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> updateMissionUserByMissionUserId(body, provider) async {
  final res = apiPatchRequest(
      'MissionUser/updateMissionUserByMissionUserId', body, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database PATCH error';
  }
}

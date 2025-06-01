import 'api_init.dart';

Future<dynamic> getMissionUsersByChallengeId(id) async {
  final res = apiGetRequest(
      'MissionUser/getMissionUsersByChallengeId', {"missionId": id});
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

Future<dynamic> getMissionUsersByUserId(id) async {
  final res =
      apiGetRequest('MissionUser/getMissionUsersByUserId', {"userId": id});
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

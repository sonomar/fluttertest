import 'api_init.dart';

Future<dynamic> getMissionByMissionId(id, provider) async {
  final res = apiGetRequest(
      'Mission/getMissionByMissionId', {"missionId": id}, provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

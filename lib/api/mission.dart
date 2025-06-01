import 'api_init.dart';

Future<dynamic> getMissionByMissionId(id) async {
  final res = apiGetRequest('Mission/getMissionByMissionId', {"missionId": id});
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

import 'api_init.dart';

Future<dynamic> getCommunityChallengeByCommunityChallengeId(
    id, provider) async {
  final res = apiGetRequest(
      'CommunityChallenge/getCommunityChallengeByCommunityChallengeId',
      {"communityChallengeId": id},
      provider);
  if (res != null) {
    return res;
  } else {
    throw ' database GET error';
  }
}

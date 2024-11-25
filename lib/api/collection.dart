import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> _getJWTCode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwtCode') as String;
}

final userPool = CognitoUserPool(
  'eu-central-1_flxgJwy19',
  '3habrhuviqskit3ma595m5dp0b',
);

void main() async {
  final credentials = CognitoCredentials(
      'eu-central-1:a053a3b2-6679-43f3-80b9-bd9f105e404a', userPool);
  await credentials.getAwsCredentials(_getJWTCode());

  const endpoint =
      'https://mnj4pgmr1h.execute-api.eu-central-1.amazonaws.com/kloopocar_dev';

  // final awsSigV4Client = AwsSigV4Client(
  //     credentials.accessKeyId, credentials.secretAccessKey, endpoint,
  //     serviceName: 'appsync',
  //     sessionToken: credentials.sessionToken,
  //     region: 'eu-central-1');
}

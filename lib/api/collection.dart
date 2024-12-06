import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> _getJWTCode() async {
  // ignore: avoid_print
  print('STEP 2');
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwtIdCode') as String;
}

final userPool = CognitoUserPool(
  'eu-central-1_flxgJwy19',
  '3habrhuviqskit3ma595m5dp0b',
);

void getAllCollectibles() async {
  // ignore: avoid_print
  print('STEP 1');
  final credentials = CognitoCredentials(
      'eu-central-1:a053a3b2-6679-43f3-80b9-bd9f105e404a', userPool);
  var code = await _getJWTCode();
  // ignore: avoid_print
  print('CODE: $code');
  print(credentials.accessKeyId);
  await credentials.getAwsCredentials(code);

  const endpoint =
      'https://mnj4pgmr1h.execute-api.eu-central-1.amazonaws.com/kloopocar_dev';

  final awsSigV4Client = AwsSigV4Client(
      credentials.accessKeyId ?? 'no access key found',
      credentials.secretAccessKey ?? 'no secret key found',
      endpoint,
      serviceName: 'appsync',
      sessionToken: credentials.sessionToken,
      region: 'eu-central-1');

  final signedRequest = SigV4Request(awsSigV4Client,
      method: 'GET',
      path: '/getAllCollectibles',
      // queryParams: Map<String, String>.from({'tracking': 'x123'}),
      body: Map<String, dynamic>.from({'color': 'blue'}));

  http.Response? response;
  try {
    response = await http.get(
      signedRequest.url as Uri,
    );
  } catch (e) {
    // ignore: avoid_print
    print('STEP ERROR');
    // ignore: avoid_print
    print(e);
  }
  // ignore: avoid_print
  print(response?.body);
}

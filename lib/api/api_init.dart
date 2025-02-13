import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<String> _getJWTIdCode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwtIdCode') as String;
}

Future<String> _getJWTCode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwtCode') as String;
}

final userPool = CognitoUserPool(
  'eu-central-1_flxgJwy19',
  '3habrhuviqskit3ma595m5dp0b',
);

final jwtIdCode = _getJWTIdCode();
final jwtCode = _getJWTCode();

const endpoint =
    'https://mnj4pgmr1h.execute-api.eu-central-1.amazonaws.com/kloopocar_dev';

Future<AwsSigV4Client> getCredentials() async {
  final credentials = CognitoCredentials(
      'eu-central-1:a053a3b2-6679-43f3-80b9-bd9f105e404a', userPool);
  var code = await jwtIdCode;
  await credentials.getAwsCredentials(code);
  final awsSigV4Client = AwsSigV4Client(
      credentials.accessKeyId ?? 'no access key found',
      credentials.secretAccessKey ?? 'no secret key found',
      endpoint,
      serviceName: 'appsync',
      sessionToken: credentials.sessionToken,
      region: 'eu-central-1');
  return awsSigV4Client;
}

Future getQuery(path, headers, query, body) async {
  final userCode = await jwtCode;
  final amazonCredentials = await getCredentials();
  final signedRequest = SigV4Request(amazonCredentials,
      method: 'GET',
      path: path,
      headers: headers,
      queryParams: query,
      // queryParams: Map<String, String>.from({'tracking': 'x123'}),
      body: body);

  http.Response? response;

  try {
    response = await http.get(
      Uri.parse(signedRequest.url ?? 'no request found'),
      headers: {'Authorization': userCode},
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

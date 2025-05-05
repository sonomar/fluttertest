import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getJWTCode(code) async {
  // ignore: avoid_print
  print('STEP 2');
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(code) as String;
}

final userPool = CognitoUserPool(
  'eu-central-1_flxgJwy19',
  '3habrhuviqskit3ma595m5dp0b',
);

apiGetRequest(
  String path,
  Map<String, dynamic> paramsContent,
) async {
  // ignore: avoid_print
  const endpoint =
      'https://mnj4pgmr1h.execute-api.eu-central-1.amazonaws.com/kloopocar_dev';
  final credentials = CognitoCredentials(
      'eu-central-1:a053a3b2-6679-43f3-80b9-bd9f105e404a', userPool);
  var code = await getJWTCode('jwtIdCode');
  var userCode = await getJWTCode('jwtCode');
  // ignore: avoid_print
  print('CODE: $code');
  await credentials.getAwsCredentials(code);
  print(credentials.accessKeyId);
  print(credentials.secretAccessKey);
  print(credentials.sessionToken);
  // ignore: avoid_print

  final awsSigV4Client = AwsSigV4Client(
      credentials.accessKeyId ?? 'no access key found',
      credentials.secretAccessKey ?? 'no secret key found',
      endpoint,
      serviceName: 'appsync',
      sessionToken: credentials.sessionToken,
      region: 'eu-central-1');

  final signedRequest = SigV4Request(
    awsSigV4Client,
    method: 'GET',
    path: path,
    headers: {'Access-Control-Allow-Origin': '*', 'Authorization': code},
    //body: Map<String, String>.from({}),
    queryParams: Map<String, String>.from(paramsContent),
    body: Map<String, dynamic>.from(paramsContent),
  );

  http.Response? response;
  print(signedRequest.url ?? 'no request found');
  try {
    response = await http.get(
      Uri.parse(signedRequest.url ?? 'no request found'),
      headers: Map<String, String>.from(
          {'Access-Control-Allow-Origin': '*', 'Authorization': userCode}),
    );
  } catch (e) {
    // ignore: avoid_print
    print('ERROR');
  }
  // ignore: avoid_print
  print(response?.body);
}

apiPatchRequest(
  String path,
  Map<String, dynamic> bodyContent,
) async {
  // ignore: avoid_print
  const endpoint =
      'https://mnj4pgmr1h.execute-api.eu-central-1.amazonaws.com/kloopocar_dev';
  final credentials = CognitoCredentials(
      'eu-central-1:a053a3b2-6679-43f3-80b9-bd9f105e404a', userPool);
  var code = await getJWTCode('jwtIdCode');
  var userCode = await getJWTCode('jwtCode');
  // ignore: avoid_print
  print('CODE: $code');
  await credentials.getAwsCredentials(code);
  print(credentials.accessKeyId);
  print(credentials.secretAccessKey);
  print(credentials.sessionToken);
  // ignore: avoid_print

  final awsSigV4Client = AwsSigV4Client(
      credentials.accessKeyId ?? 'no access key found',
      credentials.secretAccessKey ?? 'no secret key found',
      endpoint,
      serviceName: 'appsync',
      sessionToken: credentials.sessionToken,
      region: 'eu-central-1');

  final signedRequest = SigV4Request(awsSigV4Client,
      method: 'PATCH',
      path: path,
      headers: {'Authorization': code, 'Content-Type': 'application/json'},
      //body: Map<String, String>.from({}),
      body: Map<String, dynamic>.from(bodyContent));

  http.Response? response;
  print(signedRequest.url ?? 'no request found');
  try {
    response =
        await http.patch(Uri.parse(signedRequest.url ?? 'no request found'),
            headers: Map<String, String>.from({
              'Authorization': userCode,
              'Content-Type': 'application/json',
            }),
            body: signedRequest.body);
  } catch (e) {
    // ignore: avoid_print
    print('ERROR');
  }
  // ignore: avoid_print
  print(response?.body);
}

apiPostRequest(
  String path,
  Map<String, dynamic> bodyContent,
) async {
  // ignore: avoid_print
  const endpoint =
      'https://mnj4pgmr1h.execute-api.eu-central-1.amazonaws.com/kloopocar_dev';
  final credentials = CognitoCredentials(
      'eu-central-1:a053a3b2-6679-43f3-80b9-bd9f105e404a', userPool);
  var code = await getJWTCode('jwtIdCode');
  var userCode = await getJWTCode('jwtCode');
  // ignore: avoid_print
  print('CODE: $code');
  await credentials.getAwsCredentials(code);
  print(credentials.accessKeyId);
  print(credentials.secretAccessKey);
  print(credentials.sessionToken);
  // ignore: avoid_print

  final awsSigV4Client = AwsSigV4Client(
      credentials.accessKeyId ?? 'no access key found',
      credentials.secretAccessKey ?? 'no secret key found',
      endpoint,
      serviceName: 'appsync',
      sessionToken: credentials.sessionToken,
      region: 'eu-central-1');

  final signedRequest = SigV4Request(awsSigV4Client,
      method: 'POST',
      path: path,
      headers: {'Authorization': code, 'Content-Type': 'application/json'},
      //body: Map<String, String>.from({}),
      body: Map<String, dynamic>.from(bodyContent));

  http.Response? response;
  print(signedRequest.url ?? 'no request found');
  try {
    response =
        await http.post(Uri.parse(signedRequest.url ?? 'no request found'),
            headers: Map<String, String>.from({
              'Authorization': userCode,
              'Content-Type': 'application/json',
            }),
            body: signedRequest.body);
  } catch (e) {
    // ignore: avoid_print
    print('ERROR');
  }
  // ignore: avoid_print
  print(response?.body);
}

apiDeleteRequest(
  String path,
  Map<String, dynamic> paramsContent,
) async {
  // ignore: avoid_print
  const endpoint =
      'https://mnj4pgmr1h.execute-api.eu-central-1.amazonaws.com/kloopocar_dev';
  final credentials = CognitoCredentials(
      'eu-central-1:a053a3b2-6679-43f3-80b9-bd9f105e404a', userPool);
  var code = await getJWTCode('jwtIdCode');
  var userCode = await getJWTCode('jwtCode');
  // ignore: avoid_print
  print('CODE: $code');
  await credentials.getAwsCredentials(code);
  print(credentials.accessKeyId);
  print(credentials.secretAccessKey);
  print(credentials.sessionToken);
  // ignore: avoid_print

  final awsSigV4Client = AwsSigV4Client(
      credentials.accessKeyId ?? 'no access key found',
      credentials.secretAccessKey ?? 'no secret key found',
      endpoint,
      serviceName: 'appsync',
      sessionToken: credentials.sessionToken,
      region: 'eu-central-1');

  final signedRequest = SigV4Request(
    awsSigV4Client,
    method: 'DELETE',
    path: path,
    headers: {'Authorization': code, 'Content-Type': 'application/json'},
    //body: Map<String, String>.from({}),
    queryParams: Map<String, String>.from(paramsContent),
    body: Map<String, dynamic>.from(paramsContent),
  );

  http.Response? response;
  print(signedRequest.url ?? 'no request found');
  try {
    response =
        await http.delete(Uri.parse(signedRequest.url ?? 'no request found'),
            headers: Map<String, String>.from({
              'Authorization': userCode,
              'Content-Type': 'application/json',
            }),
            body: signedRequest.body);
  } catch (e) {
    // ignore: avoid_print
    print('ERROR');
  }
  // ignore: avoid_print
  print(response?.body);
}

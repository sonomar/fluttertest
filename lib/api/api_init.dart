import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/app_auth_provider.dart';

getEnvItem(item) {
  var endpoint = dotenv.env[item];
  if (endpoint != null) {
    return endpoint;
  } else {
    return 'no API endpoint found';
  }
}

final endpoint = getEnvItem('API_URL');
final identityPool = getEnvItem('COGNITO_IP_URL');
final clientRegion = getEnvItem('COGNITO_UP_REGION');
final clientId = getEnvItem('COGNITO_UP_CLIENTID');

final userPool = CognitoUserPool(
  clientRegion,
  clientId,
);

Future<dynamic> apiGetRequest(
  String path,
  Map<String, dynamic> paramsContent,
  AppAuthProvider authProvider,
) async {
  await dotenv.load(fileName: ".env");
  // ignore: avoid_print
  final credentials = CognitoCredentials(identityPool, userPool);
  final currentIdToken = authProvider.idToken;

  if (currentIdToken == null) {
    print('Current ID Token: $currentIdToken');
    print('API Call failed: No valid ID token found after checkUser.');
    // Handle unauthenticated state, e.g., throw an error, return null,
    // or navigate to login. For now, we'll just return null.
    return null;
  }
  await credentials.getAwsCredentials(currentIdToken);
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
    headers: {
      'Authorization': currentIdToken,
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    //body: Map<String, String>.from({}),
    queryParams: Map<String, String>.from(paramsContent),
    body: Map<String, dynamic>.from(paramsContent),
  );

  http.Response? response;
  print(signedRequest.url ?? 'no request found');
  try {
    response = await http.get(
      Uri.parse(signedRequest.url ?? 'no request found'),
      headers: Map<String, String>.from({
        'Content-Type': 'application/json',
        'Authorization': currentIdToken
      }),
    );
  } catch (e) {
    // ignore: avoid_print
    print('ERROR during GET request: $e');
  }
  print('Response body: ${response?.body}');
  if (response != null) {
    if (response.statusCode == 401) {
      print(
          'Unauthorized! Token might be expired. checkUser should handle this.');
      // You might want to trigger re-authentication or logout flow here
    }
    return json.decode(response.body);
  }
  return null; // Or throw a specific exception
}

Future<dynamic> apiPatchRequest(
  String path,
  Map<String, dynamic> bodyContent,
  AppAuthProvider authProvider,
) async {
  await dotenv.load(fileName: ".env");
  // ignore: avoid_print
  final credentials = CognitoCredentials(identityPool, userPool);
  final currentIdToken = authProvider.idToken;

  if (currentIdToken == null) {
    print('Current ID Token: $currentIdToken');
    print('API Call failed: No valid ID token found after checkUser.');
    // Handle unauthenticated state, e.g., throw an error, return null,
    // or navigate to login. For now, we'll just return null.
    return null;
  }
  await credentials.getAwsCredentials(currentIdToken);
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
      headers: {
        'Authorization': currentIdToken,
        'Content-Type': 'application/json'
      },
      //body: Map<String, String>.from({}),
      body: Map<String, dynamic>.from(bodyContent));

  http.Response? response;
  print(signedRequest.url ?? 'no request found');
  // ignore: prefer_interpolation_to_compose_strings
  try {
    response =
        await http.patch(Uri.parse(signedRequest.url ?? 'no request found'),
            headers: Map<String, String>.from({
              'Authorization': currentIdToken,
              'Content-Type': 'application/json',
            }),
            body: signedRequest.body);
  } catch (e) {
    // ignore: avoid_print
    print('ERROR');
  }
  // ignore: avoid_print
  print(response?.body);
  if (response != null) {
    return json.decode(response.body);
  }
}

Future<dynamic> apiPostRequest(
  String path,
  Map<String, dynamic> bodyContent,
  AppAuthProvider authProvider,
) async {
  await dotenv.load(fileName: ".env");
  // ignore: avoid_print
  final credentials = CognitoCredentials(identityPool, userPool);
  final currentIdToken = authProvider.idToken;

  if (currentIdToken == null) {
    print('Current ID Token: $currentIdToken');
    print('API Call failed: No valid ID token found after checkUser.');
    // Handle unauthenticated state, e.g., throw an error, return null,
    // or navigate to login. For now, we'll just return null.
    return null;
  }
  await credentials.getAwsCredentials(currentIdToken);
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
      headers: {
        'Authorization': currentIdToken,
        'Content-Type': 'application/json'
      },
      //body: Map<String, String>.from({}),
      body: Map<String, dynamic>.from(bodyContent));

  http.Response? response;
  print(signedRequest.url ?? 'no request found');
  try {
    response =
        await http.post(Uri.parse(signedRequest.url ?? 'no request found'),
            headers: Map<String, String>.from({
              'Authorization': currentIdToken,
              'Content-Type': 'application/json',
            }),
            body: signedRequest.body);
  } catch (e) {
    // ignore: avoid_print
    print('ERROR');
  }
  // ignore: avoid_print
  print(response?.body);
  if (response != null) {
    return json.decode(response.body);
  }
}

apiDeleteRequest(
  String path,
  Map<String, dynamic> paramsContent,
  AppAuthProvider authProvider,
) async {
  await dotenv.load(fileName: ".env");
  // ignore: avoid_print
  final credentials = CognitoCredentials(identityPool, userPool);
  final currentIdToken = authProvider.idToken;

  if (currentIdToken == null) {
    print('Current ID Token: $currentIdToken');
    print('API Call failed: No valid ID token found after checkUser.');
    // Handle unauthenticated state, e.g., throw an error, return null,
    // or navigate to login. For now, we'll just return null.
    return null;
  }
  await credentials.getAwsCredentials(currentIdToken);
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
    headers: {
      'Authorization': currentIdToken,
      'Content-Type': 'application/json'
    },
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
              'Authorization': currentIdToken,
              'Content-Type': 'application/json',
              'Accept': "*/*"
            }),
            body: signedRequest.body);
  } catch (e) {
    // ignore: avoid_print
    print('ERROR');
  }
  // ignore: avoid_print
  print(response?.body);
  if (response != null) {
    return json.decode(response.body);
  }
}

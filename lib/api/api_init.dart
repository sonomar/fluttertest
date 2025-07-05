import 'package:http/http.dart' as http;
import 'dart:convert';
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

String? _getCurrentUserSub(AppAuthProvider authProvider) {
  final userSub = authProvider.authService.currentUserSub;
  if (userSub == null) {
    print('API Call failed: Could not retrieve userSub from auth service.');
    return null;
  }
  return userSub;
}

Future<Map<String, String>> _getHeaders(AppAuthProvider? provider) async {
  final prefs = await SharedPreferences.getInstance();

  // The ONLY source of truth for the token will be SharedPreferences.
  // The 'provider' argument is now ignored for auth purposes.
  final token = prefs.getString('jwtIdCode');

  print(
      'API Init: Reading token directly from storage. Token is present: $token');

  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}

Future<dynamic> apiGetRequest(
  String path,
  Map<String, dynamic> paramsContent,
  AppAuthProvider authProvider,
) async {
  await dotenv.load(fileName: ".env");
  // ignore: avoid_print
  final credentials = CognitoCredentials(identityPool, userPool);
  final currentIdToken = authProvider.idToken;
  final headers = await _getHeaders(authProvider);

  if (currentIdToken == null) {
    print('Current ID Token: $currentIdToken');
    print('API Call failed: No valid ID token found after checkUser.');
    return null;
  }

  final userSub = authProvider.authService.currentUserSub;
  if (userSub == null) {
    print('API Call failed: Could not retrieve userSub.');
    return null;
  }
  paramsContent['username'] = userSub;
  paramsContent['sub'] = userSub;

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
    headers: headers,
    //body: Map<String, String>.from({}),
    queryParams: Map<String, String>.from(paramsContent),
    body: Map<String, dynamic>.from(paramsContent),
  );

  http.Response? response;
  print(signedRequest.url ?? 'no request found');
  try {
    response = await http.get(
      Uri.parse(signedRequest.url ?? 'no request found'),
      headers: headers,
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
      await authProvider.signOut();
      return null;
    }
    try {
      return json.decode(response.body);
    } catch (e) {
      print('--- API PARSE ERROR ---');
      print(
          'Failed to decode JSON from response. The server returned a non-JSON response.');
      print('Path: $path');
      print('Status Code: ${response.statusCode}');
      print('Raw Response Body: ${response.body}');
      print('-----------------------');
      return null; // Return null to prevent the app from crashing.
    }
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
  final headers = await _getHeaders(authProvider);

  if (currentIdToken == null) {
    print('Current ID Token: $currentIdToken');
    print('API Call failed: No valid ID token found after checkUser.');
    return null;
  }

  final userSub = authProvider.authService.currentUserSub;
  if (userSub == null) {
    print('API Call failed: Could not retrieve userSub.');
    return null;
  }
  bodyContent['username'] = userSub;
  bodyContent['sub'] = userSub;

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
      headers: headers,
      //body: Map<String, String>.from({}),
      body: Map<String, dynamic>.from(bodyContent));

  http.Response? response;
  print(signedRequest.url ?? 'no request found');
  // ignore: prefer_interpolation_to_compose_strings
  try {
    response = await http.patch(
        Uri.parse(signedRequest.url ?? 'no request found'),
        headers: headers,
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
  final headers = await _getHeaders(authProvider);

  if (currentIdToken == null) {
    print('Current ID Token: $currentIdToken');
    print('API Call failed: No valid ID token found after checkUser.');
    return null;
  }

  final userSub = authProvider.authService.currentUserSub;
  if (userSub == null) {
    print('API Call failed: Could not retrieve userSub.');
    return null;
  }
  bodyContent['username'] = userSub;
  bodyContent['sub'] = userSub;

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
      headers: headers,
      //body: Map<String, String>.from({}),
      body: Map<String, dynamic>.from(bodyContent));

  http.Response? response;
  print(signedRequest.url ?? 'no request found');
  try {
    response = await http.post(
        Uri.parse(signedRequest.url ?? 'no request found'),
        headers: headers,
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
  final headers = await _getHeaders(authProvider);

  if (currentIdToken == null) {
    print('Current ID Token: $currentIdToken');
    print('API Call failed: No valid ID token found after checkUser.');
    return null;
  }

  final userSub = authProvider.authService.currentUserSub;
  if (userSub == null) {
    print('API Call failed: Could not retrieve userSub.');
    return null;
  }
  paramsContent['username'] = userSub;
  paramsContent['sub'] = userSub;

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
    headers: headers,
    //body: Map<String, String>.from({}),
    queryParams: Map<String, String>.from(paramsContent),
    body: Map<String, dynamic>.from(paramsContent),
  );

  http.Response? response;
  print(signedRequest.url ?? 'no request found');
  try {
    response = await http.delete(
        Uri.parse(signedRequest.url ?? 'no request found'),
        headers: headers,
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

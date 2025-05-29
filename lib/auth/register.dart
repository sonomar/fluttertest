import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './authenticate.dart';

late final String status;

getEnvItem(item) {
  var endpoint = dotenv.env[item];
  if (endpoint != null) {
    return endpoint;
  } else {
    return 'no API endpoint found';
  }
}

final clientRegion = getEnvItem('COGNITO_UP_REGION');
final clientId = getEnvItem('COGNITO_UP_CLIENTID');

Future<bool> signUpUser(email, password) async {
  await dotenv.load(fileName: ".env");
  final userPool = CognitoUserPool(
    clientRegion,
    clientId,
  );
  CognitoUserPoolData data;
  try {
    data = await userPool.signUp(
      email,
      password,
    );
    print('SIGNUP DATA:');
    print(data);
  } catch (e) {
    print(e);
  }
  await authenticateUser(email, password, true);
  return true;
}

Future<bool> emailConfirmUser(email, password, code) async {
  await dotenv.load(fileName: ".env");
  final userPool = CognitoUserPool(
    clientRegion,
    clientId,
  );

  bool registrationConfirmed = false;
  final cognitoUser = CognitoUser(email, userPool);
  try {
    registrationConfirmed = await cognitoUser.confirmRegistration(code);
  } catch (e) {
    print(e);
  }
  print(registrationConfirmed);
  // final auth = await authenticateUser(email, password, true);
  // if (auth == true && registrationConfirmed == true) {
  //   return auth;
  // }
  return false;
}

Future<void> emailResendConfirmation(email) async {
  await dotenv.load(fileName: ".env");
  final userPool = CognitoUserPool(
    clientRegion,
    clientId,
  );
  final cognitoUser = CognitoUser(email, userPool);
  try {
    status = await cognitoUser.resendConfirmationCode();
  } catch (e) {
    print(status);
  }
}

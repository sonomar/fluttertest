import 'package:amazon_cognito_identity_dart_2/cognito.dart';

late final String status;

Future<bool> signUpUser(email, password) async {
  final userPool = CognitoUserPool(
    'eu-central-1_flxgJwy19',
    '3habrhuviqskit3ma595m5dp0b',
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
  return true;
}

Future<bool> emailConfirmUser(email, code) async {
  final userPool = CognitoUserPool(
    'eu-central-1_flxgJwy19',
    '3habrhuviqskit3ma595m5dp0b',
  );

  bool registrationConfirmed = false;
  final cognitoUser = CognitoUser(email, userPool);
  try {
    registrationConfirmed = await cognitoUser.confirmRegistration(code);
  } catch (e) {
    print(e);
  }
  print(registrationConfirmed);
  return registrationConfirmed;
}

Future<void> emailResendConfirmation(email) async {
  final userPool = CognitoUserPool(
    'eu-central-1_flxgJwy19',
    '3habrhuviqskit3ma595m5dp0b',
  );
  final cognitoUser = CognitoUser(email, userPool);
  try {
    status = await cognitoUser.resendConfirmationCode();
  } catch (e) {
    print(status);
  }
}

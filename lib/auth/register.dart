import 'package:amazon_cognito_identity_dart_2/cognito.dart';

final userPool = CognitoUserPool(
  'eu-central-1_flxgJwy19',
  '3habrhuviqskit3ma595m5dp0b',
);
final userAttributes = [
  const AttributeArg(name: 'first_name', value: 'Lawtest'),
  const AttributeArg(name: 'last_name', value: 'Martest'),
];

final cognitoUser = CognitoUser('lawsonmarlowe@gmail.com', userPool);

late final String status;

Future<void> signUpUser() async {
  var data;
  try {
    data = await userPool.signUp(
      'lawsonmarlowe@gmail.com',
      'password001',
    );
    print('SIGNUP DATA:');
    print(data);
  } catch (e) {
    print(e);
  }
}

Future<void> emailConfirmUser() async {
  bool registrationConfirmed = false;
  try {
    registrationConfirmed = await cognitoUser.confirmRegistration('194685');
  } catch (e) {
    print(e);
  }
  print(registrationConfirmed);
}

Future<void> emailResendConfirmation() async {
  final String status;
  try {
    status = await cognitoUser.resendConfirmationCode();
  } catch (e) {
    print(e);
  }
}

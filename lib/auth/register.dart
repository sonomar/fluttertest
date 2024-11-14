import 'package:amazon_cognito_identity_dart_2/cognito.dart';

final userPool = CognitoUserPool(
  'ap-southeast-1_xxxxxxxxx',
  'xxxxxxxxxxxxxxxxxxxxxxxxxx',
);
final userAttributes = [
  const AttributeArg(name: 'first_name', value: 'Jimmy'),
  const AttributeArg(name: 'last_name', value: 'Wong'),
];

final cognitoUser = CognitoUser('email@inspire.my', userPool);

late final String status;

Future<void> signUpUser() async {
  var data;
  try {
    data = await userPool.signUp(
      'email@inspire.my',
      'Password001',
      userAttributes: userAttributes,
    );
  } catch (e) {
    print(e);
  }
}

Future<void> emailConfirmUser() async {
  bool registrationConfirmed = false;
  try {
    registrationConfirmed = await cognitoUser.confirmRegistration('123456');
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

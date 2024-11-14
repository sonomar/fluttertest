import 'package:amazon_cognito_identity_dart_2/cognito.dart';

final userPool = CognitoUserPool(
  'ap-southeast-1_xxxxxxxxx',
  'xxxxxxxxxxxxxxxxxxxxxxxxxx',
);
final cognitoUser = CognitoUser('email@inspire.my', userPool);
final authDetails = AuthenticationDetails(
  username: 'email@inspire.my',
  password: 'Password001',
);

Future<void> authenticateUser() async {
  CognitoUserSession? session;
  try {
    session = await cognitoUser.authenticateUser(authDetails);
  } on CognitoUserNewPasswordRequiredException catch (e) {
    // handle New Password challenge
  } on CognitoUserMfaRequiredException catch (e) {
    // handle SMS_MFA challenge
  } on CognitoUserSelectMfaTypeException catch (e) {
    // handle SELECT_MFA_TYPE challenge
  } on CognitoUserMfaSetupException catch (e) {
    // handle MFA_SETUP challenge
  } on CognitoUserTotpRequiredException catch (e) {
    // handle SOFTWARE_TOKEN_MFA challenge
  } on CognitoUserCustomChallengeException catch (e) {
    // handle CUSTOM_CHALLENGE challenge
  } on CognitoUserConfirmationNecessaryException catch (e) {
    // handle User Confirmation Necessary
  } on CognitoClientException catch (e) {
    // handle Wrong Username and Password and Cognito Client
  } catch (e) {
    print(e);
  }
  print(session?.getAccessToken().getJwtToken());
}

Future<void> getUserAttr() async {
  List<CognitoUserAttribute>? attributes;
  try {
    attributes = await cognitoUser.getUserAttributes();
  } catch (e) {
    print(e);
  }
  attributes?.forEach((attribute) {
    print('attribute ${attribute.getName()} has value ${attribute.getValue()}');
  });
}

Future<void> logOut() async {
  await cognitoUser.globalSignOut();
}

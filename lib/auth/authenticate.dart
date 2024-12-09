import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userPool = CognitoUserPool(
  'eu-central-1_flxgJwy19',
  '3habrhuviqskit3ma595m5dp0b',
);
final cognitoUser = CognitoUser('lawsonmarlowe@gmail.com', userPool);
final authDetails = AuthenticationDetails(
  username: 'lawsonmarlowe@gmail.com',
  password: 'password001',
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
  final prefs = await SharedPreferences.getInstance();
  final token = session?.getAccessToken().getJwtToken();
  final idToken = session?.getIdToken().getJwtToken();
  session != null;
  prefs.setString('jwtCode', token ?? 'Error Loggin In');
  print(token);
  prefs.setString('jwtIdCode', idToken ?? 'No ID Token');
}

Future<void> getUserAttr() async {
  List<CognitoUserAttribute>? attributes;
  try {
    attributes = await cognitoUser.getUserAttributes();
  } catch (e) {
    print(e);
  }
  attributes?.forEach((attribute) {
    print('USER ATTRIBUTES:');
    print('attribute ${attribute.getName()} has value ${attribute.getValue()}');
  });
}

Future<void> logOut() async {
  await cognitoUser.signOut();
}

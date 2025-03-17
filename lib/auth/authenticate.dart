import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> authenticateUser(email, password) async {
  final userPool = CognitoUserPool(
    'eu-central-1_flxgJwy19',
    '3habrhuviqskit3ma595m5dp0b',
  );
  //username: lawsonmarlowe@gmail.com
  //password: password001
  final cognitoUser = CognitoUser(email, userPool);
  final authDetails = AuthenticationDetails(
    username: email,
    password: password,
  );
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
    // ignore: avoid_print
    print(e);
  }
  final prefs = await SharedPreferences.getInstance();
  final token = session?.getAccessToken().getJwtToken();
  final idToken = session?.getIdToken().getJwtToken();
  session != null;
  prefs.setString('jwtCode', token ?? 'Error Loggin In');
  // ignore: avoid_print
  print(token);
  prefs.setString('jwtIdCode', idToken ?? 'No ID Token');
  return true;
}

Future<bool> getUserAttr(email) async {
  final userPool = CognitoUserPool(
    'eu-central-1_flxgJwy19',
    '3habrhuviqskit3ma595m5dp0b',
  );
  //username: lawsonmarlowe@gmail.com
  //password: password001
  final cognitoUser = CognitoUser(email, userPool);
  List<CognitoUserAttribute>? attributes;
  try {
    attributes = await cognitoUser.getUserAttributes();
  } catch (e) {
    // ignore: avoid_print
    print(e);
    return false;
  }
  attributes?.forEach((attribute) {
    // ignore: avoid_print
    print('USER ATTRIBUTES:');
    // ignore: avoid_print
    print('attribute ${attribute.getName()} has value ${attribute.getValue()}');
  });
  return true;
}

Future<void> logOut(email) async {
  final userPool = CognitoUserPool(
    'eu-central-1_flxgJwy19',
    '3habrhuviqskit3ma595m5dp0b',
  );
  final cognitoUser = CognitoUser(email, userPool);
  await cognitoUser.signOut();
}

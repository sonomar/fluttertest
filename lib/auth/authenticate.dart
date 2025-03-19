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
  } on CognitoUserNewPasswordRequiredException {
    return false;
  } on CognitoUserMfaRequiredException {
    return false;
  } on CognitoUserSelectMfaTypeException {
    return false;
  } on CognitoUserMfaSetupException {
    return false;
  } on CognitoUserTotpRequiredException {
    return false;
  } on CognitoUserCustomChallengeException {
    return false;
  } on CognitoUserConfirmationNecessaryException {
    return false;
  } on CognitoClientException {
    return false;
  } catch (e) {
    // ignore: avoid_print
    print(e);
    return false;
  }
  final prefs = await SharedPreferences.getInstance();
  final token = session?.getAccessToken().getJwtToken();
  final idToken = session?.getIdToken().getJwtToken();
  session != null;
  if (email != null) {
    prefs.setString('email', email);
  }
  if (token != null) {
    prefs.setString('jwtCode', token);
    // ignore: avoid_print
    print(token);
  }
  if (idToken != null) {
    prefs.setString('jwtIdCode', idToken);
  }
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

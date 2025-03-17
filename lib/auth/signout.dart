import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logOut(email) async {
  final userPool = CognitoUserPool(
    'eu-central-1_flxgJwy19',
    '3habrhuviqskit3ma595m5dp0b',
  );
  final cognitoUser = CognitoUser(email, userPool);
  await cognitoUser.signOut();
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('email');
  prefs.remove('jwtCode');
  prefs.remove('jwtIdCode');
}

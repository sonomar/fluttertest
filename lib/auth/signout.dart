import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

Future<void> logOut(email) async {
  await dotenv.load(fileName: ".env");
  final userPool = CognitoUserPool(
    clientRegion,
    clientId,
  );
  final cognitoUser = CognitoUser(email, userPool);
  await cognitoUser.signOut();
  final prefs = await SharedPreferences.getInstance();
  prefs.remove('email');
  prefs.remove('jwtCode');
  prefs.remove('jwtIdCode');
}

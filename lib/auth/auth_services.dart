import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class AuthService {
  final CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;

  AuthService() : _userPool = CognitoUserPool(clientRegion, clientId);

  Future<CognitoUserSession?> get currentSession async {
    await dotenv.load(fileName: ".env");
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");
    // If we already have a valid session in memory, return it immediately
    if (_session != null && _session!.isValid()) {
      return _session;
    }

    _cognitoUser = CognitoUser(email, _userPool);
    if (_cognitoUser == null) {
      return null;
    }

    try {
      // getSession will automatically attempt to renew the session
      // using the refresh token if the current tokens are expired
      // and a refresh token is available in storage.
      _session = await _cognitoUser!.getSession();

      // Ensure tokens are cached after a successful session retrieval/renewal
      // This is important for the library to find them later.
      await _cognitoUser!.cacheTokens();
      print(
          'Current session obtained/renewed. Access Token valid: ${_session!.isValid()}');
      return _session;
    } on CognitoClientException catch (e) {
      print('CognitoClientException getting session: ${e.message}');
      // Specific Cognito errors indicating session invalidity (e.g., Refresh Token expired)
      _session = null;
      _cognitoUser = null;
      await signOut(); // Force sign out and clear all storage
      return null;
    } on Exception catch (e) {
      print('Unexpected error getting session: $e');
      _session = null;
      _cognitoUser = null;
      await signOut(); // Force sign out and clear all storage
      return null;
    }
  }

  Future<void> signOut() async {
    if (_cognitoUser != null) {
      await _cognitoUser!.signOut();
    }
    _session = null;
    _cognitoUser = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('jwtCode');
    prefs.remove('jwtIdCode');
    print('User signed out.');
  }
}

// A simple wrapper for FlutterSecureStorage to fit CognitoStorage interface
// This is critical for persisting the session correctly.

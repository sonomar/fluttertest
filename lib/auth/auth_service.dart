import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kloppocar_app/api/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

getEnvItem(item) {
  var endpoint = dotenv.env[item];
  if (endpoint != null) {
    return endpoint;
  } else {
    return 'no API endpoint found';
  }
}

String encryptPassword(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

final clientRegion = getEnvItem('COGNITO_UP_REGION');
final clientId = getEnvItem('COGNITO_UP_CLIENTID');

class AuthService {
  final CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;

  AuthService() : _userPool = CognitoUserPool(clientRegion, clientId);

  Future<CognitoUserSession?> get currentSession async {
    // If we already have a valid session in memory, return it immediately
    if (_session != null && _session!.isValid()) {
      return _session;
    }

    _cognitoUser = await _userPool.getCurrentUser();
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

  Future<bool> signIn(String email, String password,
      {bool isRegister = false}) async {
    // Ensure dotenv is loaded

    // Set the internal _cognitoUser for AuthService
    _cognitoUser = CognitoUser(email, _userPool);

    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );
    int attempts = 0;
    const int maxAttempts = 3;
    const Duration retryDelay = Duration(milliseconds: 4000);

    while (attempts < maxAttempts) {
      attempts++;

      try {
        // Authenticate the user using the internal _cognitoUser
        _session = await _cognitoUser!.authenticateUser(authDetails);
        // --- CRITICAL: Cache tokens unconditionally after successful authentication ---
        // This is the most crucial part for getSession() to work later.
        await _cognitoUser!.cacheTokens();
        final prefs = await SharedPreferences.getInstance();
        // Save email for future currentSession calls
        // Added null check just in case, though email should not be null here
        prefs.setString('email', email);
        // Manually saving JWTs (optional, but harmless if you use them elsewhere)
        final token = _session?.getAccessToken().getJwtToken();
        final idToken = _session?.getIdToken().getJwtToken();
        if (token != null) {
          prefs.setString('jwtCode', token);
          print('AuthService: Access Token saved to SharedPreferences.');
        }
        if (idToken != null) {
          prefs.setString('jwtIdCode', idToken);
          print('AuthService: ID Token saved to SharedPreferences.');
        }

        if (token != null && isRegister == true) {
          // Using isRegister parameter now
          final encryptedPassword = encryptPassword(password);
          final getUser = await getUserByEmail(
              email); // Ensure getUserByEmail is accessible (e.g., imported)
          final userId = getUser['userId'];
          final userUpdateBody = {
            "userId": userId,
            "passwordHashed": encryptedPassword,
            "authToken": token
          };
          await updateUserByUserId(
              userUpdateBody); // Ensure updateUserByUserId is accessible
        }

        print(
            'AuthService: User $email signed in successfully. Session valid: ${_session!.isValid()}');
        return true; // Successfully authenticated and cached
      } on CognitoUserNewPasswordRequiredException catch (e) {
        print('AuthService Sign-in Error: New Password Required: ${e.message}');
        return false; // No retry for specific user actions required
      } on CognitoUserMfaRequiredException catch (e) {
        print('AuthService Sign-in Error: MFA Required: ${e.message}');
        return false; // No retry for specific user actions required
      } on CognitoUserSelectMfaTypeException catch (e) {
        print('AuthService Sign-in Error: Select MFA Type: ${e.message}');
        return false; // No retry for specific user actions required
      } on CognitoUserMfaSetupException catch (e) {
        print('AuthService Sign-in Error: MFA Setup: ${e.message}');
        return false; // No retry for specific user actions required
      } on CognitoUserTotpRequiredException catch (e) {
        print('AuthService Sign-in Error: TOTP Required: ${e.message}');
        return false; // No retry for specific user actions required
      } on CognitoUserCustomChallengeException catch (e) {
        print('AuthService Sign-in Error: Custom Challenge: ${e.message}');
        return false; // No retry for specific user actions required
      } on CognitoUserConfirmationNecessaryException catch (e) {
        print(
            'AuthService Sign-in Error: Confirmation Necessary: ${e.message}');
        return false; // No retry for specific user actions required
      } on CognitoClientException catch (e) {
        print(
            'AuthService Sign-in Error: Cognito Client Exception: ${e.message}. Attempt $attempts of $maxAttempts.');
        if (attempts < maxAttempts) {
          print('AuthService: Retrying in ${retryDelay.inMilliseconds}ms...');
          await Future.delayed(retryDelay);
        } else {
          // All attempts exhausted for this type of error
          print(
              'AuthService: All $maxAttempts attempts failed for user $email due to CognitoClientException.');
          return false; // Explicitly return false when retries are done
        }
      } catch (e) {
        print(
            'AuthService Sign-in Error: Unexpected error during authentication: $e. Attempt $attempts of $maxAttempts.');
        if (attempts < maxAttempts) {
          print('AuthService: Retrying in ${retryDelay.inMilliseconds}ms...');
          await Future.delayed(retryDelay);
        } else {
          // All attempts exhausted for general errors
          print(
              'AuthService: All $maxAttempts attempts failed for user $email due to unexpected error.');
          return false; // Explicitly return false when retries are done
        }
      }
    }
    print(
        'AuthService: Final return after all attempts. User $email could not be signed in.');
    return false;
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

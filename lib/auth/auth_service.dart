import 'dart:convert';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kloppocar_app/api/user.dart'; // Assuming this import provides getUserByEmail and updateUserByUserId
import 'package:shared_preferences/shared_preferences.dart';

// Helper to get environment variables safely
String getEnvItem(String item) {
  var endpoint = dotenv.env[item];
  if (endpoint != null) {
    return endpoint;
  } else {
    throw Exception(
        'Environment variable "$item" not found. Please check your .env file.');
  }
}

// Password encryption utility
String encryptPassword(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

// Correctly use userPoolId and clientId from .env
final userPoolId = getEnvItem(
    'COGNITO_UP_REGION'); // This is the user pool ID (e.g., 'us-east-1_XXXXXXX')
final clientId = getEnvItem('COGNITO_UP_CLIENTID'); // This is the app client ID

// --- Custom CognitoStorage implementation using SharedPreferences ---
class SecureCognitoStorage extends CognitoStorage {
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Future<dynamic> clear() async {
    // Changed return type to Future<dynamic>
    final prefs = await _getPrefs();
    await prefs.clear();
    print('CognitoStorage (SharedPreferences): All items cleared.');
    return null; // Return null to satisfy Future<dynamic>
  }

  @override
  Future<dynamic> getItem(String key) async {
    // Changed return type to Future<dynamic>
    final prefs = await _getPrefs();
    final value = prefs.getString(key);
    // print('CognitoStorage (SharedPreferences): Read "$key": ${value != null ? "Found" : "Not Found"}');
    return value; // String? is assignable to dynamic
  }

  @override
  Future<dynamic> removeItem(String key) async {
    // Changed return type to Future<dynamic>
    final prefs = await _getPrefs();
    await prefs.remove(key);
    print('CognitoStorage (SharedPreferences): Removed "$key".');
    return null; // Return null to satisfy Future<dynamic>
  }

  @override
  Future<dynamic> setItem(String key, dynamic value) async {
    // Changed return type to Future<dynamic> and parameter type to dynamic
    final prefs = await _getPrefs();
    if (value is String) {
      // Ensure the value is a String, as SharedPreferences.setString requires it
      await prefs.setString(key, value);
      print('CognitoStorage (SharedPreferences): Set "$key".');
      return null; // Return null to satisfy Future<dynamic>
    } else {
      // This case should ideally not happen if Cognito is only storing strings,
      // but it's good practice to handle it.
      throw ArgumentError(
          'Only String values can be stored in SharedPreferences for key: $key');
    }
  }
}
// --- END Custom CognitoStorage implementation ---

class AuthService {
  final CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session; // Internal storage for the current session
  String?
      _internalErrorMessage; // To hold specific error messages from AuthService

  AuthService()
      : _userPool = CognitoUserPool(
          userPoolId, // Use the userPoolId from env
          clientId, // Use the clientId from env
          storage: SecureCognitoStorage(), // Pass your custom storage here!
        );

  // Expose the current valid session for AppAuthProvider to use
  CognitoUserSession? get session => _session;

  // Expose internal error messages
  String? get errorMessage => _internalErrorMessage;

  Future<bool> checkCurrentSessionStatus() async {
    _internalErrorMessage = null; // Clear previous error
    // If we already have a valid session in memory, return true immediately
    if (_session != null && _session!.isValid()) {
      print('AuthService: In-memory session is valid.');
      return true;
    }

    try {
      // Attempt to get the current user from persistent storage (via CognitoStorage which now uses SharedPreferences)
      _cognitoUser = await _userPool.getCurrentUser();
      if (_cognitoUser == null) {
        print('AuthService: No current user found in storage.');
        _session = null; // Ensure internal session is null
        return false;
      }

      // Try to get or renew the session. This is where tokens are checked/refreshed.
      _session = await _cognitoUser!.getSession();

      if (_session != null && _session!.isValid()) {
        // Crucial: Cache tokens after a successful session retrieval/renewal
        // This ensures they are persisted for future app launches via SharedPreferences.
        await _cognitoUser!.cacheTokens();
        print(
            'AuthService: Session obtained/renewed successfully and is valid.');
        return true;
      } else {
        print(
            'AuthService: Session obtained but is null or invalid. Clearing local data from storage.');
        _session = null; // Ensure internal session is null
        await _forceSignOutAndClearLocal(); // Call the consolidated sign-out
        return false;
      }
    } on CognitoClientException catch (e) {
      _internalErrorMessage =
          'Cognito Client Exception during session check: ${e.message}';
      print('AuthService: $_internalErrorMessage');
      _session = null; // Clear internal session
      await _forceSignOutAndClearLocal(); // Call the consolidated sign-out
      return false;
    } on Exception catch (e) {
      _internalErrorMessage =
          'Unexpected error during session check: ${e.toString()}';
      print('AuthService: $_internalErrorMessage');
      _session = null; // Clear internal session
      await _forceSignOutAndClearLocal(); // Call the consolidated sign-out
      return false;
    }
  }

  Future<bool> signIn(String email, String password,
      {bool isRegister = false}) async {
    _internalErrorMessage = null; // Clear any previous error message
    _cognitoUser = CognitoUser(email, _userPool);

    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );

    int attempts = 0;
    const int maxAttempts = 3;
    const Duration retryDelay = Duration(milliseconds: 500);

    while (attempts < maxAttempts) {
      attempts++;
      try {
        _session = await _cognitoUser!
            .authenticateUser(authDetails); // This updates _session
        // --- CRITICAL: Cache tokens unconditionally after successful authentication ---
        // This is the most crucial part for getSession() to work later.
        await _cognitoUser!.cacheTokens();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(
            'email', email); // Save email for future currentSession calls

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

        // Handle user registration update if needed
        if (token != null && isRegister == true) {
          final encryptedPassword = encryptPassword(password);
          final getUser = await getUserByEmail(email);
          final userId = getUser['userId'];
          final userUpdateBody = {
            "userId": userId,
            "passwordHashed": encryptedPassword,
            "authToken": token
          };
          await updateUserByUserId(userUpdateBody);
        }

        print(
            'AuthService: User $email signed in successfully. Session valid: ${_session!.isValid()}');
        return true; // Successfully authenticated and cached
      } on CognitoUserNewPasswordRequiredException catch (e) {
        _internalErrorMessage = 'New Password Required: ${e.message}';
        print('AuthService Sign-in Error: $_internalErrorMessage');
        _session = null; // Clear session on specific failure
        return false; // No retry for user action required
      } on CognitoUserMfaRequiredException catch (e) {
        _internalErrorMessage = 'MFA Required: ${e.message}';
        print('AuthService Sign-in Error: $_internalErrorMessage');
        _session = null; // Clear session on specific failure
        return false; // No retry for user action required
      } on CognitoUserSelectMfaTypeException catch (e) {
        _internalErrorMessage = 'Select MFA Type: ${e.message}';
        print('AuthService Sign-in Error: $_internalErrorMessage');
        _session = null; // Clear session on specific failure
        return false; // No retry for user action required
      } on CognitoUserMfaSetupException catch (e) {
        _internalErrorMessage = 'MFA Setup: ${e.message}';
        print('AuthService Sign-in Error: $_internalErrorMessage');
        _session = null; // Clear session on specific failure
        return false; // No retry for user action required
      } on CognitoUserTotpRequiredException catch (e) {
        _internalErrorMessage = 'TOTP Required: ${e.message}';
        print('AuthService Sign-in Error: $_internalErrorMessage');
        _session = null; // Clear session on specific failure
        return false; // No retry for user action required
      } on CognitoUserCustomChallengeException catch (e) {
        _internalErrorMessage = 'Custom Challenge: ${e.message}';
        print('AuthService Sign-in Error: $_internalErrorMessage');
        _session = null; // Clear session on specific failure
        return false; // No retry for user action required
      } on CognitoUserConfirmationNecessaryException catch (e) {
        _internalErrorMessage = 'Confirmation Necessary: ${e.message}';
        print('AuthService Sign-in Error: $_internalErrorMessage');
        _session = null; // Clear session on specific failure
        return false; // No retry for user action required
      } on CognitoClientException catch (e) {
        _internalErrorMessage = 'Cognito Client Exception: ${e.message}';
        print(
            'AuthService Sign-in Error: $_internalErrorMessage. Attempt $attempts of $maxAttempts.');
        _session = null; // Clear session on this type of failure
        if (attempts < maxAttempts) {
          print('AuthService: Retrying in ${retryDelay.inMilliseconds}ms...');
          await Future.delayed(retryDelay);
        } else {
          // All attempts exhausted for this type of error
          print(
              'AuthService: All $maxAttempts attempts failed for user $email due to CognitoClientException. Signing out.');
          await _forceSignOutAndClearLocal(); // Call the consolidated sign-out
          return false;
        }
      } catch (e) {
        _internalErrorMessage =
            'Unexpected error during authentication: ${e.toString()}';
        print(
            'AuthService Sign-in Error: $_internalErrorMessage. Attempt $attempts of $maxAttempts.');
        _session = null; // Clear session on this type of failure
        if (attempts < maxAttempts) {
          print('AuthService: Retrying in ${retryDelay.inMilliseconds}ms...');
          await Future.delayed(retryDelay);
        } else {
          // All attempts exhausted for general errors
          print(
              'AuthService: All $maxAttempts attempts failed for user $email due to unexpected error. Signing out.');
          await _forceSignOutAndClearLocal(); // Call the consolidated sign-out
          return false;
        }
      }
    }
    _internalErrorMessage =
        'All login attempts failed without a specific error.';
    print(
        'AuthService: Final return after all attempts. User $email could not be signed in.');
    await _forceSignOutAndClearLocal(); // Call the consolidated sign-out if loop finishes without success
    _session = null;
    return false;
  }

  Future<void> signOut() async {
    // Calling CognitoUser.signOut() clears Cognito's internal cached tokens via CognitoStorage (now SharedPreferences)
    if (_cognitoUser != null) {
      await _cognitoUser!.signOut();
      print(
          'AuthService: CognitoUser.signOut() called to clear internal storage.');
    }
    await _clearSharedPreferences(); // Call the new private method to clear shared preferences
    _session = null; // Clear internal session object
    _cognitoUser = null; // Clear internal CognitoUser object
    _internalErrorMessage = null; // Clear error message on sign out
    print('AuthService: User signed out and all relevant local data cleared.');
  }

  // Private method to consolidate local data clearing
  Future<void> _clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print(
        'AuthService: All SharedPreferences data cleared (including non-auth).');
  }

  // Private method for forced sign-out and local data clearing
  // This is used when a session is found to be invalid or an error occurs.
  Future<void> _forceSignOutAndClearLocal() async {
    // Attempt to clear Cognito's internal storage if a user object exists
    if (_cognitoUser != null) {
      try {
        await _cognitoUser!.signOut();
        print(
            'AuthService: Forced CognitoUser.signOut() for invalid session from storage.');
      } catch (e) {
        print('AuthService: Error during forced CognitoUser.signOut(): $e');
      }
    }
    await _clearSharedPreferences(); // Always clear shared preferences
    _session = null;
    _cognitoUser = null;
    _internalErrorMessage = null;
    print('AuthService: Forced sign-out and local data cleared.');
  }
}

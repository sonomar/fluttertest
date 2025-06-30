import 'dart:convert';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_auth_provider.dart';
import '../api/user.dart';

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
  AppAuthProvider? _appAuthProvider;

  AuthService.uninitialized()
      : _userPool = CognitoUserPool(
          userPoolId,
          clientId,
          storage: SecureCognitoStorage(),
        );

  String? get currentUserSub {
    if (_session != null && _session!.isValid()) {
      final idToken = _session!.getIdToken().getJwtToken();
      if (idToken == null) return null;
      final parts = idToken.split('.');
      if (parts.length != 3) {
        // Not a valid JWT structure
        return null;
      }
      final payloadString =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payloadMap = json.decode(payloadString);
      if (payloadMap is Map<String, dynamic>) {
        debugPrint('tesst: ${payloadMap['sub']}');
        return payloadMap['sub'];
      }
    }
    return null;
  }

  // Setter to inject AppAuthProvider AFTER AuthService is created
  void setAppAuthProvider(AppAuthProvider provider) {
    _appAuthProvider = provider;
    print('AuthService: AppAuthProvider injected.');
  }

  AuthService(this._appAuthProvider)
      : _userPool = CognitoUserPool(
          userPoolId, // Use the userPoolId from env
          clientId, // Use the clientId from env
          storage: SecureCognitoStorage(), // Pass your custom storage here!
        );

  // Expose the current valid session for AppAuthProvider to use
  CognitoUserSession? get session => _session;

  // Expose internal error messages
  String? get errorMessage => _internalErrorMessage;

  Future<bool> signUp(
      {required String email,
      required String password,
      required Map customAttributes}) async {
    _internalErrorMessage = null;
    final List<AttributeArg> userAttributes = [
      // Always include the email as a standard attribute.
      AttributeArg(name: 'email', value: email),
    ];

    // Add your custom attributes, ensuring they are prefixed with 'custom:'.
    customAttributes.forEach((key, value) {
      // Use the AttributeArg class here as well.
      userAttributes.add(AttributeArg(name: 'custom:$key', value: value));
    });
    try {
      await _userPool.signUp(email, password, userAttributes: userAttributes);
      // If no exception is thrown, Cognito has sent a confirmation code.
      print(
          'AuthService: SignUp successful for $email. Awaiting confirmation.');
      return true;
    } on CognitoClientException catch (e) {
      // Handle known Cognito errors, e.g., UsernameExistsException
      _internalErrorMessage = e.message ?? 'An unknown sign-up error occurred.';
      print('AuthService: SignUp Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage = 'An unexpected error occurred during sign-up.';
      print('AuthService: SignUp Error: $e');
      return false;
    }
  }

  Future<bool> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    _internalErrorMessage = null; // Clear previous errors
    final cognitoUser = CognitoUser(email, _userPool);
    try {
      // The `confirmRegistration` method returns a bool indicating success.
      final isConfirmed =
          await cognitoUser.confirmRegistration(confirmationCode);
      print('AuthService: Confirmation for $email successful: $isConfirmed');
      return isConfirmed;
    } on CognitoClientException catch (e) {
      // Handle known Cognito errors, e.g., CodeMismatchException
      _internalErrorMessage =
          e.message ?? 'An unknown confirmation error occurred.';
      print('AuthService: Confirmation Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage =
          'An unexpected error occurred during confirmation.';
      print('AuthService: Confirmation Error: $e');
      return false;
    }
  }

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
    final cognitoUser = CognitoUser(email, _userPool);

    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );

    try {
      final CognitoUserSession? newSession =
          await cognitoUser.authenticateUser(authDetails);
      if (newSession == null || !newSession.isValid()) {
        throw Exception('Authentication returned a null or invalid session.');
      }
      _session = newSession;
      _cognitoUser = cognitoUser;
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
        print('token $token');
      }
      if (idToken != null) {
        prefs.setString('jwtIdCode', idToken);
        print('AuthService: ID Token saved to SharedPreferences.');
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
      _session = null; // Clear session on this type of failure
      // All attempts exhausted for this type of error
      print(
          'AuthService: attempt failed for user $email due to CognitoClientException. Signing out.');
      await _forceSignOutAndClearLocal(); // Call the consolidated sign-out
      return false;
    } catch (e) {
      _internalErrorMessage =
          'Unexpected error during authentication: ${e.toString()}';
      print(
          'AuthService: Attempt failed for user $email due to unexpected error. Signing out.');
      await _forceSignOutAndClearLocal(); // Call the consolidated sign-out
      return false;
    }
  }

  Future<bool> signInWithEmailCode(String email) async {
    _internalErrorMessage = null;
    _cognitoUser = CognitoUser(email, _userPool);

    try {
      // This call will trigger your 'Define Auth Challenge' Lambda.
      await _cognitoUser!.initiateAuth(AuthenticationDetails(username: email));
      return true;
    } on CognitoUserCustomChallengeException {
      // This is the expected successful outcome. It means Cognito is asking for the code.
      return true;
    } catch (e) {
      _internalErrorMessage = "Error initiating email login: ${e.toString()}";
      return false;
    }
  }

  /// NEW: Verifies the code sent to the user's email to complete the login.
  Future<bool> answerEmailCodeChallenge(String answer) async {
    _internalErrorMessage = null;
    if (_cognitoUser == null) {
      _internalErrorMessage = "Login session expired. Please try again.";
      return false;
    }
    try {
      _session = await _cognitoUser!.sendCustomChallengeAnswer(answer);
      if (_session?.isValid() ?? false) {
        // Persist the session tokens to secure storage.
        await _cognitoUser!.cacheTokens();
        final prefs = await SharedPreferences.getInstance();
        if (_cognitoUser!.username != null) {
          prefs.setString('email', _cognitoUser!.username!);
        }

        final token = _session?.getAccessToken().getJwtToken();
        final idToken = _session?.getIdToken().getJwtToken();
        if (token != null) {
          prefs.setString('jwtCode', token);
        }
        if (idToken != null) {
          prefs.setString('jwtIdCode', idToken);
        }

        final attributes = await _cognitoUser!.getUserAttributes();
        final userIdAttr = attributes?.firstWhere(
            (attr) => attr.getName() == 'custom:userId',
            orElse: () =>
                CognitoUserAttribute(name: 'custom:userId', value: null));
        if (userIdAttr?.getValue() != null) {
          await prefs.setString('userId', userIdAttr!.getValue()!);
        }

        return true;
      }
      return false;
    } catch (e) {
      _internalErrorMessage =
          "Failed to verify code. It may be incorrect or expired.";
      return false;
    }
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
    print(
        'AuthService: User signed out and all relevant local data cleared. _cognitoUser is now $_cognitoUser.');
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

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _internalErrorMessage = null;
    // First, ensure we have a valid session and user object.
    if (_cognitoUser == null || _session == null || !_session!.isValid()) {
      _internalErrorMessage = "You must be logged in to change your password.";
      return false;
    }

    try {
      await _cognitoUser!.changePassword(oldPassword, newPassword);
      print('AuthService: Password changed successfully.');
      return true;
    } on CognitoClientException catch (e) {
      _internalErrorMessage =
          e.message ?? "An error occurred while changing password.";
      print('AuthService: ChangePassword Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage = 'An unexpected error occurred.';
      print('AuthService: ChangePassword Error: $e');
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _internalErrorMessage = null;
    final cognitoUser = CognitoUser(email, _userPool);
    try {
      await cognitoUser.forgotPassword();
      // Store the user object so we can use it in the confirmation step.
      _cognitoUser = cognitoUser;
      print('AuthService: Forgot password process initiated for $email.');
      return true;
    } on CognitoClientException catch (e) {
      _internalErrorMessage = e.message ?? 'An unknown error occurred.';
      print('AuthService: ForgotPassword Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage = 'An unexpected error occurred.';
      print('AuthService: ForgotPassword Error: $e');
      return false;
    }
  }

  Future<bool> confirmForgotPassword({
    required String email,
    required String confirmationCode,
    required String newPassword,
  }) async {
    _internalErrorMessage = null;
    // Use the stored user from the previous step, or create a new one.
    final cognitoUser = _cognitoUser ?? CognitoUser(email, _userPool);

    try {
      final bool passwordConfirmed =
          await cognitoUser.confirmPassword(confirmationCode, newPassword);
      if (!passwordConfirmed) {
        _internalErrorMessage =
            "Password could not be confirmed. The code may be incorrect or expired.";
        return false;
      }
      print('AuthService: Password confirmed successfully for $email.');
      return true;
    } on CognitoClientException catch (e) {
      _internalErrorMessage =
          e.message ?? 'An error occurred during password confirmation.';
      print(
          'AuthService: Cognito ConfirmPassword Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage =
          'An unexpected error occurred during password confirmation.';
      print('AuthService: Internal ConfirmPassword Error: $e');
      return false;
    }
  }

  /// Initiates the process of updating the user's email address.
  /// This will send a verification code to the [newEmail].
  Future<bool> updateUserEmail({
    required String newEmail,
  }) async {
    _internalErrorMessage = null;
    if (_cognitoUser == null || _session == null || !_session!.isValid()) {
      _internalErrorMessage = "You must be logged in to change your email.";
      return false;
    }

    try {
      final attributes = [
        CognitoUserAttribute(name: 'email', value: newEmail),
      ];
      await _cognitoUser!.updateAttributes(attributes);
      print(
          'AuthService: Update email initiated. Verification code sent to $newEmail.');
      return true;
    } on CognitoClientException catch (e) {
      _internalErrorMessage =
          e.message ?? "An error occurred while updating email.";
      print('AuthService: UpdateEmail Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage = 'An unexpected error occurred.';
      print('AuthService: UpdateEmail Error: $e');
      return false;
    }
  }

  /// Verifies the new email address with the provided code.
  Future<bool> verifyUserEmail({
    required String verificationCode,
  }) async {
    _internalErrorMessage = null;
    if (_cognitoUser == null) {
      _internalErrorMessage = "User not found. Please log in again.";
      return false;
    }

    try {
      await _cognitoUser!.verifyAttribute('email', verificationCode);
      print('AuthService: Email attribute verified successfully.');
      // After a successful verification, it's best practice to force a re-login
      // to ensure the user's session tokens are updated with the new email.
      return true;
    } on CognitoClientException catch (e) {
      _internalErrorMessage = e.message ?? "Invalid verification code.";
      print('AuthService: VerifyEmail Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage = 'An unexpected error occurred.';
      print('AuthService: VerifyEmail Error: $e');
      return false;
    }
  }

  Future<bool> deleteAccount({required String userId}) async {
    _internalErrorMessage = null;
    // Ensure we have a valid, authenticated user to delete.
    if (_cognitoUser == null || _session == null || !_session!.isValid()) {
      _internalErrorMessage = "You must be logged in to delete your account.";
      return false;
    }

    try {
      // Step 1: Deactivate the user in your backend database.
      print('AuthService: Deactivating user in backend database...');
      final userUpdateBody = {
        "userId": userId,
        "active": false,
      };
      await updateUserByUserId(userUpdateBody, _appAuthProvider);
      print('AuthService: Backend user record deactivated.');

      // Step 2: Delete the user from the Cognito User Pool.
      print('AuthService: Deleting user from Cognito...');
      await _cognitoUser!.deleteUser();
      print('AuthService: Cognito user deleted successfully.');

      return true;
    } on CognitoClientException catch (e) {
      _internalErrorMessage =
          e.message ?? "An error occurred while deleting your Cognito account.";
      print('AuthService: DeleteAccount Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage =
          'An unexpected error occurred during account deletion.';
      print('AuthService: DeleteAccount Error: $e');
      return false;
    }
  }
}

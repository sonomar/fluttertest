import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_auth_provider.dart';
import '../api/user.dart';
import '../helpers/auth_error_helper.dart';

class UserNotConfirmedException implements Exception {
  final String message;
  UserNotConfirmedException(this.message);
}

// Helper to get environment variables safely
String getEnvItem(String item) {
  var endpoint = dotenv.env[item];
  if (endpoint != null) {
    return endpoint;
  } else {
    throw Exception(
        'Environment variable not found. Please check your .env file');
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
final clientId = getEnvItem('COGNITO_UP_CLIENTID');
// NEW: Add your Cognito User Pool domain
final cognitoDomain = getEnvItem('COGNITO_DOMAIN');
// NEW: Get the Google Web Client ID for server-side verification
final googleWebClientId =
    getEnvItem('GOOGLE_WEB_CLIENT_ID'); // This is the app client ID

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
  String? _internalErrorMessage;
  AppAuthProvider? _appAuthProvider;

  AuthService(this._appAuthProvider)
      : _userPool = CognitoUserPool(
          userPoolId,
          clientId,
          storage: SecureCognitoStorage(),
        );

  AuthService.uninitialized()
      : _appAuthProvider = null,
        _userPool = CognitoUserPool(
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

  // Expose the current valid session for AppAuthProvider to use
  CognitoUserSession? get session => _session;

  // Expose internal error messages
  String? get errorMessage => _internalErrorMessage;

  Future<void> launchSignInWithProvider(String provider) async {
    _internalErrorMessage = null;
    final String providerName =
        (provider.toLowerCase() == 'google') ? 'Google' : 'SignInWithApple';

    final url =
        'https://$cognitoDomain/login?response_type=token&client_id=$clientId&redirect_uri=deinsapp://callback&identity_provider=$providerName';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      // Use launchInBrowser for better handling on simulators and devices
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _internalErrorMessage = 'Could not launch login page.';
    }
  }

  Future<bool> handleRedirect(Uri uri) async {
    _internalErrorMessage = null;
    try {
      final fragment = uri.fragment;
      final params = Uri.splitQueryString(fragment);

      final idTokenString = params['id_token'];
      final accessTokenString = params['access_token'];

      if (idTokenString == null || accessTokenString == null) {
        _internalErrorMessage = 'Login failed. Tokens not found in redirect.';
        return false;
      }

      final idToken = CognitoIdToken(idTokenString);
      final accessToken = CognitoAccessToken(accessTokenString);

      _session = CognitoUserSession(idToken, accessToken);

      final claims = idToken.decodePayload();
      final userEmail = claims['email'];
      if (userEmail == null) {
        _internalErrorMessage = 'Email not found in token.';
        return false;
      }
      _cognitoUser = CognitoUser(userEmail, _userPool);
      await _cognitoUser!.cacheTokens();

      // THIS IS THE FIX:
      // Manually set the "LastAuthUser" key so that checkCurrentUser()
      // can find this user on the next app launch or resume.
      final prefs = await SharedPreferences.getInstance();
      final lastAuthUserKey =
          'CognitoIdentityServiceProvider.$clientId.LastAuthUser';
      await prefs.setString(lastAuthUserKey, userEmail);

      print('Successfully handled redirect and created session.');
      return true;
    } catch (e) {
      _internalErrorMessage = 'Error handling redirect: ${e.toString()}';
      return false;
    }
  }

  Future<String> signUp(
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
      print(
          'AuthService: SignUp successful for $email. Awaiting confirmation.');
      return 'success'; // Return 'success' on success
    } on CognitoClientException catch (e) {
      _internalErrorMessage = simplifyAuthError(e.message);
      print('AuthService: SignUp Error: $_internalErrorMessage');

      // MODIFICATION: Check for the specific exception and return it
      if (e.name == 'UsernameExistsException') {
        print(
            "AuthService: User already exists but may be unconfirmed. Resending confirmation code.");
        await resendConfirmationCode(email);
        return 'success'; // Return 'success' to proceed to the confirmation view
      }
      return 'failed'; // Return 'failed' for other errors
    } catch (e) {
      _internalErrorMessage = 'app_auth_provider_signup_unexpected';
      print('AuthService: SignUp Error: $e');
      return 'failed'; // Return 'failed' for unexpected errors
    }
  }

  Future<void> resendConfirmationCode(String email) async {
    try {
      final cognitoUser = CognitoUser(email, _userPool);
      await cognitoUser.resendConfirmationCode();
      print("AuthService: Resent confirmation code to $email.");
    } catch (e) {
      print("AuthService: Error resending confirmation code: $e");
      // Don't throw an error here, as the primary flow should continue.
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
          _internalErrorMessage = simplifyAuthError(e.message);
      print('AuthService: Confirmation Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage = simplifyAuthError(e.toString());
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
          _internalErrorMessage = simplifyAuthError(e.message);
      print('AuthService: $_internalErrorMessage');
      _session = null; // Clear internal session
      await _forceSignOutAndClearLocal(); // Call the consolidated sign-out
      return false;
    } on Exception catch (e) {
      _internalErrorMessage = simplifyAuthError(e.toString());
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
      await resendConfirmationCode(email);
      throw UserNotConfirmedException('Please confirm your account.');
    } on CognitoClientException catch (e) {
      _internalErrorMessage = simplifyAuthError(e.message);
      _session = null; // Clear session on this type of failure
      // All attempts exhausted for this type of error
      print(
          'AuthService: attempt failed for user $email due to CognitoClientException. Signing out.');
      await _forceSignOutAndClearLocal(); // Call the consolidated sign-out
      return false;
    } catch (e) {
      _internalErrorMessage = simplifyAuthError(e.toString());
      print(
          'AuthService: Attempt failed for user $email due to unexpected error. Signing out.');
      await _forceSignOutAndClearLocal(); // Call the consolidated sign-out
      return false;
    }
  }

  Future<bool> signInWithEmailCode(String email) async {
    _internalErrorMessage = null;
    final prefs = await SharedPreferences.getInstance();

    // Manually construct and send the request to Cognito's InitiateAuth endpoint
    final cognitoEndpoint =
        'https://cognito-idp.${_userPool.getRegion()}.amazonaws.com/';
    final clientId = _userPool.getClientId();

    try {
      final response = await http.post(
        Uri.parse(cognitoEndpoint),
        headers: {
          'Content-Type': 'application/x-amz-json-1.1',
          'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth',
        },
        body: jsonEncode({
          'AuthFlow': 'CUSTOM_AUTH', // Specify the custom authentication flow
          'ClientId': clientId,
          'AuthParameters': {
            'USERNAME': email,
          },
        }),
      );

      final responseBody = jsonDecode(response.body);

      // A successful initiation will return a 200 OK and a session string
      if (response.statusCode == 200 && responseBody['Session'] != null) {
        // THIS IS THE KEY: We have captured the session.
        // Persist the email and the session string immediately.
        await prefs.setString('email', email);
        await prefs.setString('emailForAuthChallenge', email);
        await prefs.setString(
            'cognitoChallengeSession', responseBody['Session']);

        print('Custom challenge initiated via direct API call. Session saved.');
        return true; // Success, we are ready for the user to enter the code.
      } else {
        // Handle errors from Cognito
        _internalErrorMessage =
            responseBody['message'] ?? 'Failed to initiate login.';
        return false;
      }
    } catch (e) {
      _internalErrorMessage =
          'An unexpected network error occurred: ${e.toString()}';
      return false;
    }
  }

  Future<bool> answerEmailCodeChallenge(String email, String answer) async {
    _internalErrorMessage = null;
    final prefs = await SharedPreferences.getInstance();

    final savedEmail = prefs.getString('emailForAuthChallenge');
    final savedSession = prefs.getString('cognitoChallengeSession');

    if (savedEmail == null || savedSession == null || savedEmail != email) {
      _internalErrorMessage = 'Your session has expired. Please try again.';
      return false;
    }

    final cognitoEndpoint =
        'https://cognito-idp.${_userPool.getRegion()}.amazonaws.com/';
    final clientId = _userPool.getClientId();

    try {
      final response = await http.post(
        Uri.parse(cognitoEndpoint),
        headers: {
          'Content-Type': 'application/x-amz-json-1.1',
          'X-Amz-Target':
              'AWSCognitoIdentityProviderService.RespondToAuthChallenge',
        },
        body: jsonEncode({
          'ClientId': clientId,
          'ChallengeName': 'CUSTOM_CHALLENGE',
          'Session': savedSession,
          'ChallengeResponses': {
            'USERNAME': email,
            'ANSWER': answer,
          },
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          responseBody['AuthenticationResult'] != null) {
        final authResult = responseBody['AuthenticationResult'];
        final idToken = CognitoIdToken(authResult['IdToken']);
        final accessToken = CognitoAccessToken(authResult['AccessToken']);
        final refreshToken = CognitoRefreshToken(authResult['RefreshToken']);

        _session = CognitoUserSession(idToken, accessToken,
            refreshToken: refreshToken);
        _cognitoUser =
            CognitoUser(email, _userPool, signInUserSession: _session);

        await _cognitoUser!.cacheTokens();

        // *** START: THIS IS THE FINAL FIX ***
        // Manually save the JWTs for your API helper to use.
        final token = _session?.getAccessToken().getJwtToken();
        final idTokenString = _session?.getIdToken().getJwtToken();
        if (token != null) {
          await prefs.setString('jwtCode', token);
          print('AuthService: Access Token saved to SharedPreferences.');
        }
        if (idTokenString != null) {
          await prefs.setString('jwtIdCode', idTokenString);
          print('AuthService: ID Token saved to SharedPreferences.');
        }
        // *** END: THIS IS THE FINAL FIX ***

        await prefs.setString('email', email);
        print('AuthService: Saved email to SharedPreferences.');

        final attributes = await _cognitoUser!.getUserAttributes();
        final userIdAttr = attributes?.firstWhere(
            (attr) => attr.getName() == 'custom:userId',
            orElse: () =>
                CognitoUserAttribute(name: 'custom:userId', value: null));

        if (userIdAttr?.getValue() != null) {
          await prefs.setString('userId', userIdAttr!.getValue()!);
          print('AuthService: Saved userId to SharedPreferences.');
        }

        await prefs.remove('emailForAuthChallenge');
        await prefs.remove('cognitoChallengeSession');

        print('Successfully answered challenge and created session.');
        return true;
      } else {
        _internalErrorMessage = responseBody['message'] ??
            'The code you entered is incorrect. Please try again.';
        if (responseBody['__type']?.contains('NotAuthorizedException') ??
            false) {
          await prefs.remove('emailForAuthChallenge');
          await prefs.remove('cognitoChallengeSession');
          _internalErrorMessage =
              'Your session has expired. Please start the login process again.';
        }
        return false;
      }
    } catch (e) {
      _internalErrorMessage =
          'An unexpected network error occurred: ${e.toString()}';
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
      _internalErrorMessage = 'You must be logged in to change your password.';
      return false;
    }

    try {
      await _cognitoUser!.changePassword(oldPassword, newPassword);
      print('AuthService: Password changed successfully.');
      return true;
    } on CognitoClientException catch (e) {
      _internalErrorMessage =
          _internalErrorMessage = simplifyAuthError(e.message);
      print('AuthService: ChangePassword Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage = simplifyAuthError(e.toString());
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
      _internalErrorMessage = simplifyAuthError(e.message);
      print('AuthService: ForgotPassword Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage = simplifyAuthError(e.toString());
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
            'Password could not be confirmed. The code may be incorrect or expired.l';
        return false;
      }
      print('AuthService: Password confirmed successfully for $email.');
      return true;
    } on CognitoClientException catch (e) {
      _internalErrorMessage =
          _internalErrorMessage = simplifyAuthError(e.message);
      print(
          'AuthService: Cognito ConfirmPassword Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage = simplifyAuthError(e.toString());
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
      _internalErrorMessage = 'You must be logged in to change your email.';
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
          _internalErrorMessage = simplifyAuthError(e.message);
      print('AuthService: UpdateEmail Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage = simplifyAuthError(e.toString());
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
      _internalErrorMessage = 'You must be logged in to change your email.';
      return false;
    }

    try {
      await _cognitoUser!.verifyAttribute('email', verificationCode);
      print('AuthService: Email attribute verified successfully.');
      // After a successful verification, it's best practice to force a re-login
      // to ensure the user's session tokens are updated with the new email.
      return true;
    } on CognitoClientException catch (e) {
      _internalErrorMessage = simplifyAuthError(e.message);
      print('AuthService: VerifyEmail Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage = simplifyAuthError(e.toString());
      print('AuthService: VerifyEmail Error: $e');
      return false;
    }
  }

  Future<bool> deleteAccount({required String userId}) async {
    _internalErrorMessage = null;
    // Ensure we have a valid, authenticated user to delete.
    if (_cognitoUser == null || _session == null || !_session!.isValid()) {
      _internalErrorMessage = 'You must be logged in to delete your account.';
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
          _internalErrorMessage = simplifyAuthError(e.message);
      print('AuthService: DeleteAccount Error: $_internalErrorMessage');
      return false;
    } catch (e) {
      _internalErrorMessage = simplifyAuthError(e.toString());
      print('AuthService: DeleteAccount Error: $e');
      return false;
    }
  }
}

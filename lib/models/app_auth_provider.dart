import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import '../auth/auth_service.dart';

enum AuthStatus {
  uninitialized, // App is just starting
  authenticating, // Checking session or performing login/logout
  authenticated, // User has a valid, active session
  unauthenticated, // User is not logged in or session expired
  confirming
}

class AppAuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.uninitialized;
  CognitoUserSession? _userSession; // Holds the active session if authenticated
  String? _errorMessage;
  bool isNewUser = false; // Error message for the UI
  String? _emailForConfirmation;
  bool get shouldShowOnboardingForNewUser => isNewUser;

  AppAuthProvider(this._authService) {
    checkCurrentUser();
  }

  AuthStatus get status => _status;
  AuthService get authService => _authService;
  CognitoUserSession? get userSession => _userSession;
  String? get errorMessage => _errorMessage;
  String? get idToken => _userSession?.getIdToken().getJwtToken();
  String? get accessToken => _userSession?.getAccessToken().getJwtToken();
  String? get refreshToken => _userSession?.getRefreshToken()?.getToken();
  String? get emailForConfirmation => _emailForConfirmation;

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void completeNewUserOnboarding() {
    if (isNewUser) {
      isNewUser = false;
      // Notify listeners in case any part of the UI needs to react to this change.
      notifyListeners();
    }
  }

  Future<void> launchSignInWithProvider(String provider) async {
    _errorMessage = null;
    notifyListeners();
    await _authService.launchSignInWithProvider(provider);
    if (_authService.errorMessage != null) {
      _errorMessage = _authService.errorMessage;
      notifyListeners();
    }
  }

  Future<bool> handleRedirect(Uri uri) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    final success = await _authService.handleRedirect(uri);
    if (success) {
      _userSession = _authService.session;
      _status = AuthStatus.authenticated;
    } else {
      _errorMessage = _authService.errorMessage;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
    return success;
  }

  Future<void> checkCurrentUser() async {
    print('AppAuthProvider: Initiating session check...');
    _status = AuthStatus.authenticating;
    _errorMessage = null; // Clear previous errors
    notifyListeners();

    try {
      // Call the new method from AuthService to check authentication status
      final bool isAuthenticated =
          await _authService.checkCurrentSessionStatus(); // <--- Corrected call

      if (isAuthenticated) {
        // If AuthService confirms authentication, retrieve the session object from it
        _userSession = _authService.session; // <--- Access the session getter
        if (_userSession != null && _userSession!.isValid()) {
          print(
              'AppAuthProvider: Session confirmed valid and user is authenticated.');
          _status = AuthStatus.authenticated;
        } else {
          // This case should ideally not happen if isAuthenticated is true, but as a safeguard.
          print(
              'AppAuthProvider: AuthService reported authenticated, but session object is invalid. Forcing unauthenticated.');
          _status = AuthStatus.unauthenticated;
          _userSession = null;
        }
      } else {
        // If AuthService returns false, user is not authenticated
        print(
            'AppAuthProvider: No valid session found. User is unauthenticated.');
        _status = AuthStatus.unauthenticated;
        _userSession = null; // Ensure session is null
        _errorMessage = _authService
            .errorMessage; // Get specific error if AuthService had one
      }
    } catch (e) {
      // Catch any unexpected errors during this AppAuthProvider's check process
      _errorMessage =
          'AppAuthProvider Error during session check: ${e.toString()}';
      print(_errorMessage);
      _status = AuthStatus.unauthenticated;
      _userSession = null;
    } finally {
      notifyListeners(); // Notify UI about the final status
    }
  }

  Future<bool> signIn(String username, String password,
      {bool isRegister = false}) async {
    print(
        'AppAuthProvider: signIn started for $username. Current status: $_status at ${DateTime.now()}');
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    if (isRegister) {
      isNewUser = true;
    }
    print(
        'AppAuthProvider: signIn status set to authenticating. Notifying. at ${DateTime.now()}');
    notifyListeners();
    try {
      final bool authServiceSuccess =
          await _authService.signIn(username, password, isRegister: isRegister);
      if (authServiceSuccess) {
        print(
            'AppAuthProvider: AuthService.signIn reported success. Verifying session. at ${DateTime.now()}');
        _userSession = _authService.session;

        if (_userSession != null && _userSession!.isValid()) {
          print(
              'AppAuthProvider: Session confirmed valid after signIn. at ${DateTime.now()}');
          _status = AuthStatus.authenticated;
          print(
              'AppAuthProvider: signIn status set to authenticated. Notifying. at ${DateTime.now()}');
          notifyListeners();
          await Future.delayed(Duration(milliseconds: 50)); // Give it 50ms
          print(
              'AppAuthProvider: Post-notification delay completed. at ${DateTime.now()}');

          print(
              'AppAuthProvider: Login process completed successfully. User authenticated. at ${DateTime.now()}');
          return true;
        } else {
          _errorMessage = _authService.errorMessage ??
              'app_auth_provider_signin_invalidsession';
          print('AppAuthProvider: $_errorMessage');
          isNewUser = false;
          _status = AuthStatus.unauthenticated;
          _userSession = null;
          print(
              'AppAuthProvider: signIn status set to unauthenticated (session invalid). Notifying. at ${DateTime.now()}');
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = _authService.errorMessage ??
            'auth_error_helper_simplify_unexpected';
        _status = AuthStatus.unauthenticated;
        _userSession = null;
        print(
            'AppAuthProvider: signIn status set to unauthenticated (auth service failed). Notifying. at ${DateTime.now()}');
        notifyListeners();
        return false;
      }
    } on UserNotConfirmedException catch (e) {
      print(
          "AppAuthProvider: Caught UserNotConfirmedException. Navigating to confirmation.");
      _emailForConfirmation =
          username; // Store the email for the confirmation screen
      _status = AuthStatus.confirming; // Set state to show confirmation screen
      _errorMessage = e.message;
      notifyListeners();
      return false; // Login did not complete, but we are handling the flow.
    } catch (e) {
      // --- MODIFICATION: Add a fallback error key ---
      // This ensures _errorMessage is never null on failure.
      _errorMessage =
          _authService.errorMessage ?? 'auth_error_helper_simplify_unexpected';
      print('AppAuthProvider: $_errorMessage');
      _status = AuthStatus.unauthenticated;
      _userSession = null;
      print(
          'AppAuthProvider: signIn status set to unauthenticated (exception). Notifying. at ${DateTime.now()}');
      notifyListeners();
      return false;
    }
  }

  Future<bool> initiateEmailLogin(String email) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    _emailForConfirmation = email;
    notifyListeners();

    final success = await _authService.signInWithEmailCode(email);
    if (!success) {
      _errorMessage = _authService.errorMessage;
      _status = AuthStatus.unauthenticated;
    }
    // On success, the status remains 'authenticating' as we wait for the code.
    notifyListeners();
    return success;
  }

  /// NEW: Completes the passwordless login by verifying the email code.
  Future<bool> answerEmailCodeChallenge(String code) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    if (_emailForConfirmation == null) {
      _errorMessage = "app_auth_provider_answer_sessionexpired";
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    final success = await _authService.answerEmailCodeChallenge(
        _emailForConfirmation!, code);
    if (success) {
      _userSession = _authService.session;
      _status = AuthStatus.authenticated;
      _emailForConfirmation = null;
    } else {
      _errorMessage = _authService.errorMessage;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
    return success;
  }

  Future<String> signUp({
    required String email,
    required String password,
    required Map customAttributes,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    final String result = await _authService.signUp(
        email: email, password: password, customAttributes: customAttributes);

    if (result == 'success') {
      _emailForConfirmation = email; // Store email
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('emailForRegistrationConfirmation', email);
      print('AppAuthProvider: Saved email for registration confirmation.');
      _status = AuthStatus.confirming; // Move to confirmation state
      isNewUser = true;
    } else {
      _errorMessage = _authService.errorMessage;
      _status = AuthStatus.unauthenticated; // Or an error state
    }
    notifyListeners();
    return result;
  }

  Future<bool> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    _errorMessage = null; // Clear previous UI error
    notifyListeners();
    String emailToConfirm = email;
    if (_emailForConfirmation == null) {
      print(
          'AppAuthProvider: In-memory email is null. Attempting to restore from SharedPreferences.');
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('emailForRegistrationConfirmation');
      if (savedEmail != null) {
        emailToConfirm = savedEmail;
        _emailForConfirmation = savedEmail; // Restore it to memory
        print('AppAuthProvider: Successfully restored email for confirmation.');
      } else {
        _errorMessage =
            "Your session has expired. Please try signing up again.";
        notifyListeners();
        return false;
      }
    }
    final success = await _authService.confirmSignUp(
        email: email, confirmationCode: confirmationCode);
    if (success) {
      // After successful confirmation, move to unauthenticated to prompt login.
      _status = AuthStatus.unauthenticated;
      _emailForConfirmation = null; // Clear the stored email
      isNewUser = false;
    } else {
      _errorMessage = _authService.errorMessage;
      _status =
          AuthStatus.confirming; // Stay on the confirmation screen on error
    }
    notifyListeners();
    return success;
  }

  Future<void> signOut() async {
    print('AppAuthProvider: Initiating sign-out...');
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
    } catch (e) {
      print(
          "AppAuthProvider: Error during _authService.signOut(), but proceeding with local sign-out. Error: $e");
    } finally {
      _userSession = null;
      _status = AuthStatus.unauthenticated;
      print('AppAuthProvider: Local sign-out complete.');
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _errorMessage = null;
    notifyListeners();
    final success = await _authService.changePassword(
        oldPassword: oldPassword, newPassword: newPassword);
    if (!success) {
      _errorMessage = _authService.errorMessage;
    }
    notifyListeners();
    return success;
  }

  Future<bool> forgotPassword(String email) async {
    _errorMessage = null;
    notifyListeners();
    final success = await _authService.forgotPassword(email);
    if (!success) {
      _errorMessage = _authService.errorMessage;
    }
    notifyListeners();
    return success;
  }

  Future<bool> confirmForgotPassword({
    required String email,
    required String confirmationCode,
    required String newPassword,
  }) async {
    _errorMessage = null;
    notifyListeners();
    final success = await _authService.confirmForgotPassword(
        email: email,
        confirmationCode: confirmationCode,
        newPassword: newPassword);
    if (!success) {
      _errorMessage = _authService.errorMessage;
    }
    notifyListeners();
    return success;
  }

  Future<bool> updateUserEmail({
    required String newEmail,
  }) async {
    _errorMessage = null;
    notifyListeners();
    final success = await _authService.updateUserEmail(newEmail: newEmail);
    if (!success) {
      _errorMessage = _authService.errorMessage;
    }
    notifyListeners();
    return success;
  }

  Future<bool> verifyUserEmail({
    required String verificationCode,
  }) async {
    _errorMessage = null;
    notifyListeners();
    final success =
        await _authService.verifyUserEmail(verificationCode: verificationCode);
    if (!success) {
      _errorMessage = _authService.errorMessage;
    }
    notifyListeners();
    return success;
  }

  Future<bool> deleteAccount({required String userId}) async {
    _errorMessage = null;
    notifyListeners();
    // Pass the userId along to the auth service.
    final success = await _authService.deleteAccount(userId: userId);
    if (!success) {
      _errorMessage = _authService.errorMessage;
      notifyListeners();
    } else {
      // If deletion is successful, trigger the sign out process.
      await signOut();
    }
    return success;
  }
}

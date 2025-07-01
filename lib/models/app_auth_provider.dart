import 'package:flutter/material.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import '../auth/auth_service.dart';

enum AuthStatus {
  uninitialized, // App is just starting
  authenticating, // Checking session or performing login/logout
  authenticated, // User has a valid, active session
  unauthenticated, // User is not logged in or session expired
}

class AppAuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.uninitialized;
  CognitoUserSession? _userSession; // Holds the active session if authenticated
  String? _errorMessage;
  bool isNewUser = false; // Error message for the UI

  AppAuthProvider(this._authService) {
    // Immediately attempt to check current user session on provider creation
    checkCurrentUser();
  }

  AuthStatus get status => _status;
  AuthService get authService => _authService;
  CognitoUserSession? get userSession => _userSession;
  String? get errorMessage => _errorMessage;
  String? get idToken => _userSession?.getIdToken().getJwtToken();
  String? get accessToken => _userSession?.getAccessToken().getJwtToken();
  String? get refreshToken => _userSession?.getRefreshToken()?.getToken();

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void completeNewUserOnboarding() {
    if (isNewUser) {
      isNewUser = false;
      // Notify listeners in case any part of the UI needs to react to this change.
      notifyListeners();
    }
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
              'Login succeeded, but session could not be confirmed as valid. at ${DateTime.now()}';
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
        print(
            'AppAuthProvider: AuthService.signIn failed. at ${DateTime.now()}');
        _errorMessage = _authService.errorMessage;
        _status = AuthStatus.unauthenticated;
        _userSession = null;
        print(
            'AppAuthProvider: signIn status set to unauthenticated (auth service failed). Notifying. at ${DateTime.now()}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage =
          'AppAuthProvider Unexpected error during login: ${e.toString()} at ${DateTime.now()}';
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

    final success = await _authService.answerEmailCodeChallenge(code);
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

  Future<String> signUp({
    required String email,
    required String password,
    required Map customAttributes,
  }) async {
    _errorMessage = null;
    notifyListeners();
    final String result = await _authService.signUp(
        email: email, password: password, customAttributes: customAttributes);

    if (result != 'success') {
      _errorMessage =
          _authService.errorMessage; // Pass service error message to UI
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
    final success = await _authService.confirmSignUp(
        email: email, confirmationCode: confirmationCode);
    if (!success) {
      _errorMessage =
          _authService.errorMessage; // Pass service error message to UI
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

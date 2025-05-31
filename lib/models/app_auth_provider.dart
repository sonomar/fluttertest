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
  CognitoUserSession? _userSession;
  String? _errorMessage;

  AppAuthProvider(this._authService) {
    // Immediately attempt to check current user session on provider creation
    checkCurrentUser();
  }

  AuthStatus get status => _status;
  CognitoUserSession? get userSession => _userSession;
  String? get errorMessage => _errorMessage;

  Future<void> checkCurrentUser() async {
    _status = AuthStatus.authenticating;
    _errorMessage = null; // Clear previous errors
    notifyListeners();

    try {
      // This call will attempt to retrieve current session or renew it using refresh token.
      _userSession = await _authService.currentSession;

      if (_userSession != null && _userSession!.isValid()) {
        print('AppAuthProvider: Session is valid and user is authenticated.');
        _status = AuthStatus.authenticated;
      } else {
        // If currentSession returns null, it means no user found or refresh token failed.
        print(
            'AppAuthProvider: No valid session found. User is unauthenticated.');
        _status = AuthStatus.unauthenticated;
        _userSession = null; // Ensure session is null if invalid
      }
    } catch (e) {
      // Catch any unexpected errors during session check
      _errorMessage = 'Error checking session: $e';
      print('AppAuthProvider: $_errorMessage');
      _status = AuthStatus.unauthenticated;
      _userSession = null;
    } finally {
      notifyListeners(); // Notify UI about the final status
    }
  }

  Future<bool> signIn(String username, String password,
      {bool isRegister = false}) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    try {
      final bool authServiceSuccess =
          await _authService.signIn(username, password, isRegister: isRegister);
      if (authServiceSuccess) {
        print(
            'AppAuthProvider: AuthService.signIn reported success. Now verifying session state...');
        // ONLY call checkCurrentUser if AuthService.signIn itself was successful.
        // This ensures SharedPreferences has caught up and the CognitoUser state is consistent.
        await checkCurrentUser();
        // After checkCurrentUser, confirm the status
        if (_status == AuthStatus.authenticated) {
          // After successful signIn, ensure session is set internally
          return true; // Login process fully successful and session established
        } else {
          // This scenario means AuthService.signIn reported success, but then
          // checkCurrentUser (which calls AuthService.currentSession) failed to establish a session.
          // This indicates a deeper inconsistency or a very short-lived valid session.
          _errorMessage = _errorMessage ??
              'Login succeeded, but session could not be confirmed.';
          print(
              'AppAuthProvider: Login succeeded, but checkCurrentUser resulted in $_status.');
          _status =
              AuthStatus.unauthenticated; // Ensure status reflects failure
          notifyListeners();
          return false;
        }
      } else {
        // AuthService.signIn explicitly failed (e.g., bad credentials, API error in user update)
        print('AppAuthProvider: AuthService.signIn failed.');
        _errorMessage =
            'Login failed. Please check your credentials or network.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Catch any unexpected exceptions during this AppAuthProvider signIn process
      _errorMessage =
          'An unexpected error occurred during login: ${e.toString()}';
      print('AppAuthProvider: $_errorMessage');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _status = AuthStatus.authenticating; // Indicate sign out is in progress
    _errorMessage = null;
    notifyListeners();
    await _authService.signOut();
    _userSession = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import '../auth/auth_services.dart';

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

  // Future<bool> signIn(String username, String password) async {
  //   _status = AuthStatus.authenticating;
  //   _errorMessage = null;
  //   notifyListeners();
  //   try {
  //     final success = await _authService.signIn(username, password);
  //     if (success) {
  //       // After successful sign-in, re-check session to ensure all tokens are loaded correctly
  //       await _checkCurrentUser();
  //       return true;
  //     } else {
  //       // Sign-in failed by AuthService, possibly due to wrong credentials.
  //       // The AuthService print statement should have more details.
  //       _errorMessage = 'Login failed. Please check your credentials.';
  //       _status = AuthStatus.unauthenticated;
  //       notifyListeners();
  //       return false;
  //     }
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     _status = AuthStatus.unauthenticated;
  //     notifyListeners();
  //     return false;
  //   }
  // }

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

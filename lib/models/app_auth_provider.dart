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
  String? _errorMessage; // Error message for the UI

  AppAuthProvider(this._authService) {
    // Immediately attempt to check current user session on provider creation
    checkCurrentUser();
  }

  AuthStatus get status => _status;
  CognitoUserSession? get userSession => _userSession;
  String? get errorMessage => _errorMessage;
  String? get idToken => _userSession?.getIdToken().getJwtToken();
  String? get accessToken => _userSession?.getAccessToken().getJwtToken();
  String? get refreshToken => _userSession?.getRefreshToken()?.getToken();

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
          notifyListeners(); // <--- This is the key notification

          // --- OPTION 2 FIX: Add a small, post-notification delay ---
          // This allows Flutter's event loop to process the notifyListeners()
          // before any subsequent rapid unmounting/rebuilding occurs.
          await Future.delayed(Duration(milliseconds: 50)); // Give it 50ms
          print(
              'AppAuthProvider: Post-notification delay completed. at ${DateTime.now()}');
          // --- END OPTION 2 FIX ---

          print(
              'AppAuthProvider: Login process completed successfully. User authenticated. at ${DateTime.now()}');
          return true;
        } else {
          _errorMessage = _authService.errorMessage ??
              'Login succeeded, but session could not be confirmed as valid. at ${DateTime.now()}';
          print('AppAuthProvider: $_errorMessage');
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

  Future<void> signOut() async {
    print('AppAuthProvider: Initiating sign-out...');
    _status = AuthStatus.authenticating; // Indicate sign out is in progress
    _errorMessage = null;
    notifyListeners();
    await _authService
        .signOut(); // This clears Cognito's local cache and SharedPreferences
    _userSession = null; // Explicitly clear local session
    _status = AuthStatus.unauthenticated;
    print('AppAuthProvider: Signed out successfully.');
    notifyListeners();
  }
}

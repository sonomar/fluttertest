import 'package:flutter/material.dart';
import '../models/app_auth_provider.dart';
import '../api/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel extends ChangeNotifier {
  final AppAuthProvider _appAuthProvider;
  dynamic _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  dynamic get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel(this._appAuthProvider);

  void clearUser() {
    _currentUser = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> updateUsername(String newUsername) async {
    if (currentUser == null) {
      _errorMessage = "No user found";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _currentUser['userId'];
      final userUpdateBody = {
        "userId": userId.toString(),
        "username": newUsername
      };
      print('mah update body: $userUpdateBody');

      // Call the API function from api/user.dart
      final result = await updateUserByUserId(userUpdateBody, _appAuthProvider);
      print('mah result: $result');
      // Your API should ideally return a clear success/error state.
      // We'll assume a non-null response indicates success for now.
      if (result != null) {
        // --- OPTIMISTIC UPDATE ---
        // Instead of calling loadUser() and causing a race condition,
        // we update the local user object directly.
        _currentUser['username'] = newUsername;
        _isLoading = false;
        notifyListeners(); // Notify the UI of the updated username.
        return true;
      } else {
        // Handle cases where the API call fails or returns an error.
        _errorMessage = "user_model_updateuser_fail";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // If the API throws an exception (e.g., for duplicate username), catch it.
      if (e.toString().toLowerCase().contains('duplicate')) {
        _errorMessage = 'onboarding_form_duplicateuser';
      } else {
        _errorMessage = "An error occurred: ${e.toString()}";
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserProfileImg(String newProfileImgUrl) async {
    if (currentUser == null) {
      _errorMessage = "user_model_updateimg_null";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _currentUser['userId'];
      // The body for the API call, assuming it accepts a 'profileImg' field.
      final userUpdateBody = {"userId": userId, "profileImg": newProfileImgUrl};

      final result = await updateUserByUserId(userUpdateBody, _appAuthProvider);

      if (result != null) {
        // Optimistic update: update the local user object directly for instant UI feedback.
        _currentUser['profileImg'] = newProfileImgUrl;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "user_model_updateimg_fail";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "An error occurred: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUser() async {
    print(
        '>>> UserModel: ENTERING loadUser() method at ${DateTime.now()} <<<'); // Should be the very first print inside loadUser()

    if (_isLoading) {
      print(
          'UserModel: loadUser() called but already loading. Returning. at ${DateTime.now()}');
      return;
    }

    _isLoading = true;
    _errorMessage = null; // Clear any previous error
    print(
        'UserModel: Setting _isLoading to true and calling notifyListeners() at ${DateTime.now()}');
    notifyListeners(); // This should cause AuthLoadingScreen to re-render with isLoading=true

    try {
      print(
          'UserModel: Attempting SharedPreferences.getInstance() at ${DateTime.now()}'); // Added print
      final prefs = await SharedPreferences
          .getInstance(); // This is a common point of hang/failure
      print(
          'UserModel: SharedPreferences.getInstance() successful at ${DateTime.now()}'); // Added print

      final userEmail = prefs.getString('email');
      final userId = prefs.getString('userId');

      if (userEmail == null && userId == null) {
        _errorMessage =
            'No user identifier found in preferences to load user data. at ${DateTime.now()}';
        print('UserModel: $_errorMessage');
        _currentUser = null;
      } else {
        print(
            'UserModel: Making API call to get user details for ${userEmail ?? userId} at ${DateTime.now()}');
        final startApiCall = DateTime.now();
        final fetchedUser = await getUserByEmail(userEmail ?? userId,
            _appAuthProvider); // Assuming getUserByEmail is defined
        print(
            'UserModel: API call completed in ${DateTime.now().difference(startApiCall).inMilliseconds}ms at ${DateTime.now()}');

        if (fetchedUser != null && fetchedUser.isNotEmpty) {
          _currentUser = fetchedUser;
          print(
              'UserModel: User data loaded successfully for ${userEmail ?? userId} at ${DateTime.now()}');
        } else {
          _errorMessage =
              'Failed to fetch user data from API for ${userEmail ?? userId}. (Empty/null response). at ${DateTime.now()}';
          print('UserModel: $_errorMessage');
          _currentUser = null;
        }
      }
    } catch (e, stackTrace) {
      // <--- Add stackTrace here for more details
      // This catch block will now catch any synchronous or asynchronous errors within the try block
      _errorMessage =
          'UserModel.loadUser() caught an error: ${e.toString()} at ${DateTime.now()}';
      print('UserModel: $_errorMessage');
      print('UserModel: Stack trace: $stackTrace'); // Log the stack trace
      _currentUser = null; // Ensure user data is cleared on error
    } finally {
      _isLoading = false; // Ensure loading state is reset
      print(
          'UserModel: END of loadUser() finally block. Setting _isLoading to false and calling notifyListeners()... at ${DateTime.now()}');
      notifyListeners(); // Notify listeners of the final state
      print(
          'UserModel: notifyListeners() called. loadUser() finished at ${DateTime.now()}');
    }
  }
}

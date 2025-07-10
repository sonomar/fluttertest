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
  bool get needsOnboarding =>
      _currentUser != null && _currentUser['userType'] == 'onboarding';

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

      // Start building the update body
      final Map<String, dynamic> userUpdateBody = {
        "userId": userId.toString(),
        "username": newUsername
      };

      // If the user is currently in the onboarding state,
      // add the userType update to the same API call.
      if (needsOnboarding) {
        userUpdateBody["userType"] = "email";
      }

      final result = await updateUserByUserId(userUpdateBody, _appAuthProvider);

      if (result != null) {
        // Optimistically update the local user object for instant UI feedback.
        _currentUser['username'] = newUsername;
        // Also update the userType locally if it was changed.
        if (needsOnboarding) {
          _currentUser['userType'] = 'email';
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "failed to update user account";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('duplicate')) {
        _errorMessage = 'Duplicate user found, choose another username.';
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
      _errorMessage = "The image update failed and returned null";
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
        _errorMessage = "The image update failed.";
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

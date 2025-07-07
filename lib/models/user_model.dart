import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_auth_provider.dart';
import '../models/mission_model.dart';
import '../api/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/user_collectible.dart';

class UserModel extends ChangeNotifier {
  final AppAuthProvider _appAuthProvider;
  dynamic _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel(this._appAuthProvider) {
    // Listen to authentication state changes to automatically load or clear user data.
    _appAuthProvider.addListener(_onAuthStateChanged);
    _onAuthStateChanged(); // Perform an initial check when the model is created.
  }

  @override
  void dispose() {
    _appAuthProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  dynamic get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _onAuthStateChanged() {
    if (_appAuthProvider.status == AuthStatus.authenticated) {
      loadCurrentUser();
    } else {
      clearUser();
    }
  }

  void clearUser() {
    _currentUser = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    if (_isLoading ||
        (_currentUser != null &&
            _appAuthProvider.status == AuthStatus.authenticated)) return;

    if (_appAuthProvider.status != AuthStatus.authenticated) {
      print("UserModel: Cannot load user, not authenticated.");
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userSub = _appAuthProvider.authService.currentUserSub;
      if (userSub == null) {
        throw Exception("Could not get user SUB from auth service.");
      }
      final email =
          _appAuthProvider.userSession?.getIdToken().decodePayload()['email'];
      if (email == null) {
        throw Exception("Could not get user email from auth session.");
      }

      // 2. Use the existing getUserByEmail function with the email.
      final userData = await getUserByEmail(email, _appAuthProvider);
      // --- END: THE FIX ---

      if (userData != null) {
        // Handle API potentially returning a list
        if (userData is List && userData.isNotEmpty) {
          _currentUser = userData.first;
        } else if (userData is Map<String, dynamic>) {
          _currentUser = userData;
        } else {
          throw Exception("User data received in unexpected format.");
        }
      } else {
        throw Exception("Failed to fetch user data from API.");
      }
    } catch (e) {
      _errorMessage = "Failed to load user profile: ${e.toString()}";
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeOnboarding(
      String newUsername, BuildContext context) async {
    if (currentUser == null) {
      _errorMessage = "Cannot complete onboarding: current user is null.";
      notifyListeners();
      return false;
    }

    // Only proceed if the user is actually in the 'onboarding' state.
    if (_currentUser['userType'] != 'onboarding') {
      print(
          "User is not in onboarding state. Proceeding with normal username update.");
      return await updateUsername(newUsername);
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Immediately update the user's type to 'email' to prevent this flow from running again.
      // This also sets their chosen username.
      final initialUpdateBody = {
        "userId": _currentUser['userId'],
        "username": newUsername,
        "type": "email"
      };
      final updateResult =
          await updateUserByUserId(initialUpdateBody, _appAuthProvider);

      if (updateResult == null) {
        throw Exception("Failed to update user type and username.");
      }

      // Optimistically update the local user object.
      _currentUser['username'] = newUsername;
      _currentUser['userType'] = 'email';

      // 2. Now that the user is "locked" out of onboarding, check for collectibles.
      final userCollectibles = await getUserCollectiblesByOwnerId(
          _currentUser['userId'].toString(), _appAuthProvider);

      // 3. If they have collectibles, update mission progress.
      if (userCollectibles is List && userCollectibles.isNotEmpty) {
        print(
            "Onboarding: User has pre-existing collectibles. Updating mission progress.");
        await _updateInitialMissionProgress(context);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "An error occurred during onboarding: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false; // Return false but don't block the user from proceeding.
    }
  }

  /// Helper function to handle the one-time mission progress update for new users.
  Future<void> _updateInitialMissionProgress(BuildContext context) async {
    final missionModel = context.read<MissionModel>();
    // Ensure the mission model has the latest data for this user.
    await missionModel.loadMissions(forceClear: true);

    for (var missionUser in missionModel.missionUsers) {
      if (missionUser['progress'] == 0) {
        print("Updating progress for mission ID: ${missionUser['missionId']}");
        await missionModel.updateMissionProgress(missionUser, 1);
      }
    }
  }

  Future<bool> updateUsername(String newUsername) async {
    if (currentUser == null) {
      _errorMessage = "user_model_updateuser_null";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _currentUser['userId'];
      final userUpdateBody = {
        "userId": userId,
        "username": newUsername,
        "userType": "email"
      };

      // Call the API function from api/user.dart
      final result = await updateUserByUserId(userUpdateBody, _appAuthProvider);

      // Your API should ideally return a clear success/error state.
      // We'll assume a non-null response indicates success for now.
      if (result != null) {
        // --- OPTIMISTIC UPDATE ---
        // Instead of calling loadUser() and causing a race condition,
        // we update the local user object directly.
        _currentUser['username'] = newUsername;
        _currentUser['userType'] = 'email';
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

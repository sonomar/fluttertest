import 'package:flutter/material.dart';
import '../api/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel extends ChangeNotifier {
  dynamic _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  dynamic get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearUser() {
    _currentUser = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadUser() async {
    if (_isLoading) {
      print('userModel: Load user already in progress. Skipping.');
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');

      if (email == null) {
        _errorMessage =
            'User email not found in preferences after authentication.';
        _currentUser = null;
        print('UserModel: Error: $_errorMessage');
      } else {
        final user = await getUserByEmail(email);
        _currentUser = user;
        print('UserModel: User data loaded for ${user['email']}');
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data: ${e.toString()}';
      _currentUser = null;
      print('Error loading collectible data: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

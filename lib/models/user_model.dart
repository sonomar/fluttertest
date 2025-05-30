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

  Future<void> loadUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      _currentUser = await getUserByEmail(email);
    } catch (e) {
      print('Error loading collectible data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import '../api/collectible.dart';
import '../api/user_collectible.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectibleModel extends ChangeNotifier {
  dynamic _collectionCollectibles;
  dynamic _userCollectibles;
  bool _isLoading = false;
  String? _errorMessage;

  dynamic get collectionCollectibles => _collectionCollectibles;
  dynamic get userCollectibles => _userCollectibles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCollectibles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      _collectionCollectibles = await getCollectiblesByCollectionId('1');
      _userCollectibles = await getUserCollectiblesByOwnerId(userId);
    } catch (e) {
      print('Error loading collectible data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

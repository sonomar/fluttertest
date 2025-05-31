import 'package:flutter/material.dart';
import '../api/collectible.dart';
import '../api/user_collectible.dart';
import '../helpers/sort_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectibleModel extends ChangeNotifier {
  dynamic _collectionCollectibles;
  dynamic _userCollectibles;
  bool _isLoading = false;
  bool _sortByName = false;
  String? _errorMessage;

  dynamic get collectionCollectibles => _collectionCollectibles;
  dynamic get userCollectibles => _userCollectibles;
  bool get isLoading => _isLoading;
  bool get sortByName => _sortByName;
  String? get errorMessage => _errorMessage;

  Future<void> loadCollectibles() async {
    _isLoading = true;
    _errorMessage = null;
    _sortByName = false;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      _collectionCollectibles = await getCollectiblesByCollectionId('1');
      _userCollectibles = await getUserCollectiblesByOwnerId(userId);
      sortData(_collectionCollectibles, "name");
    } catch (e) {
      print('Error loading collectible data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sortCollectiblesByColumn(column) async {
    if (_sortByName == true) {
      _sortByName = false;
    } else {
      _sortByName = true;
    }
    notifyListeners();
    try {
      sortData(_collectionCollectibles, column);
    } catch (e) {
      print('Error sorting collectible data: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> addUserCollectible(userId, collectibleId, mint) async {
    try {
      await createUserCollectible(userId, collectibleId, mint);
      _userCollectibles = await getUserCollectiblesByOwnerId(userId);
    } catch (e) {
      print('Error creating userCollectible data: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateCollectible(body) async {
    try {
      await updateCollectibleByCollectibleId(body);
    } catch (e) {
      print('Error creating userCollectible data: $e');
    } finally {
      notifyListeners();
    }
  }
}

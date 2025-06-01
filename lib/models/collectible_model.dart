import 'package:flutter/material.dart';
import '../api/collectible.dart';
import '../api/user_collectible.dart';
import '../helpers/sort_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectibleModel extends ChangeNotifier {
  List<dynamic> _collectionCollectibles = [];
  List<dynamic> _userCollectibles = [];
  bool _isLoading = false;
  bool _sortByName = false;
  String? _errorMessage;

  List<dynamic> get collectionCollectibles => _collectionCollectibles;
  List<dynamic> get userCollectibles => _userCollectibles;
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
      final String? userId = prefs.getString('userId');
      final dynamic fetchedCollectionData =
          await getCollectiblesByCollectionId('1');
      print(
          'DEBUG: Fetched collection data type: ${fetchedCollectionData.runtimeType}');
      print('DEBUG: Fetched collection data: $fetchedCollectionData');
      if (fetchedCollectionData is List) {
        _collectionCollectibles = fetchedCollectionData;
        print(
            'DEBUG: Collection collectibles loaded successfully. Count: ${_collectionCollectibles.length}');
      } else {
        // If not a List, it's an unexpected type or null. Default to empty list.
        _collectionCollectibles = [];
        print(
            'ERROR: getCollectiblesByCollectionId did not return a List. Type: ${fetchedCollectionData.runtimeType}');
        _errorMessage = 'Failed to load collection data: Unexpected format.';
      }
      if (userId == null) {
        // If userId is null, we can't fetch user collectibles.
        // This is where the 'null is not a subtype of String' for userId might come from.
        _userCollectibles = []; // Ensure it's an empty list
        print('WARNING: userId is null. Cannot fetch user collectibles.');
        _errorMessage =
            (_errorMessage ?? '') + ' User ID not found.'; // Append error
      } else {
        final dynamic fetchedUserData =
            await getUserCollectiblesByOwnerId(userId);
        print('DEBUG: Fetched user data type: ${fetchedUserData.runtimeType}');
        print('DEBUG: Fetched user data: $fetchedUserData');
        if (fetchedUserData is List) {
          _userCollectibles = fetchedUserData;
          print(
              'DEBUG: User collectibles loaded successfully. Count: ${_userCollectibles.length}');
        } else {
          _userCollectibles = [];
          print(
              'ERROR: getUserCollectiblesByOwnerId did not return a List. Type: ${fetchedUserData.runtimeType}');
          _errorMessage =
              '${_errorMessage ?? ''} Failed to load user collectibles: Unexpected format.';
        }
      }
      if (_collectionCollectibles.isNotEmpty) {
        // sortData should handle dynamic content. Ensure it's safe within sort_data.dart
        sortData(_collectionCollectibles, "name");
        print('DEBUG: Collection collectibles sorted by name.');
      } else {
        print('WARNING: No collection collectibles to sort.');
      }
    } catch (e) {
      // This catch block will now mostly catch errors from API calls themselves (network, server)
      _errorMessage = 'Error loading collectible data: ${e.toString()}';
      print('Error loading collectible data: $e');
      // Ensure lists are empty on any catch, so UI doesn't break on nulls
      _collectionCollectibles = [];
      _userCollectibles = [];
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

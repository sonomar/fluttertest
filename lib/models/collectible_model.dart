import 'package:flutter/material.dart';
import '../models/app_auth_provider.dart';
import '../api/collectible.dart';
import '../models/user_model.dart';
import '../api/user_collectible.dart';
import '../helpers/sort_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectibleModel extends ChangeNotifier {
  final AppAuthProvider _appAuthProvider;
  final UserModel userModel;
  List<dynamic> _collectionCollectibles = [];
  List<dynamic> _userCollectibles = [];
  bool _isLoading = false;
  bool _sortByName = true;
  bool _hasLoaded = false;
  String? _errorMessage;
  String? _loadingMessage;
  String? get loadingMessage => _loadingMessage;

  List<dynamic> get collectionCollectibles => _collectionCollectibles;
  List<dynamic> get userCollectibles => _userCollectibles;
  bool get isLoading => _isLoading;
  bool get sortByName => _sortByName;
  String? get errorMessage => _errorMessage;
  CollectibleModel(this._appAuthProvider, this.userModel);

  Future<void> loadCollectibles({bool forceClear = false}) async {
    if (_isLoading) return;
    if (_hasLoaded && !forceClear) return;

    _isLoading = true;
    _errorMessage = null;
    _loadingMessage = "Loading...";
    if (forceClear) {
      notifyListeners();
    }

    try {
      final String? userId = userModel.currentUser?['userId']?.toString();

      if (userId == null) {
        throw Exception("User ID not available from UserModel.");
      }

      // Perform both API calls concurrently for better performance.
      final results = await Future.wait([
        getCollectiblesByCollectionId('1', _appAuthProvider),
        getUserCollectiblesByOwnerId(userId, _appAuthProvider)
      ]);

      final dynamic fetchedCollectionData = results[0];
      final dynamic fetchedUserData = results[1];
      if (fetchedCollectionData is List) {
        _collectionCollectibles = fetchedCollectionData;
      } else {
        _collectionCollectibles = [];
        print('CollectibleModel: Fetched collection data was not a List.');
      }
      if (fetchedUserData is List) {
        _userCollectibles = fetchedUserData;
      } else {
        _userCollectibles = [];
        print('CollectibleModel: Fetched user data was not a List.');
      }
      _hasLoaded = true; // Mark that a successful load has occurred.
      sortData(_collectionCollectibles, _sortByName ? "name" : "label");
      // Re-apply sorting if needed
      // if (_collectionCollectibles.isNotEmpty && _sortByName) {
      //   sortCollectiblesByColumn("name");
      // } else if (_collectionCollectibles.isNotEmpty && !_sortByName) {
      //   sortCollectiblesByColumn("label"); // or your default sort
      // }
    } catch (e) {
      _errorMessage = 'Error loading collectible data: ${e.toString()}';
      print('CollectibleModel: Error in loadCollectibles: $e');
      _collectionCollectibles = [];
      _userCollectibles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSortPreference() {
    _sortByName = !_sortByName;
    String columnToSortBy = _sortByName ? "name" : "label";

    try {
      sortData(_collectionCollectibles, columnToSortBy);
    } catch (e) {
      print('Error sorting collectible data: $e');
    }
    notifyListeners();
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
      await createUserCollectible(userId.toString(), collectibleId.toString(),
          mint.toString(), _appAuthProvider); //
      await loadCollectibles(forceClear: true); // Force refresh after adding
    } catch (e) {
      _errorMessage = 'Error adding collectible: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateCollectible(body) async {
    try {
      await updateCollectibleByCollectibleId(body, _appAuthProvider);
      await loadCollectibles(forceClear: true);
    } catch (e) {
      print('Error creating userCollectible data: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateUserCollectibleStatus(String userCollectibleId,
      bool isActive, String? newOwnerId, String? previousOwnerId) async {
    // _isLoading = true;
    // notifyListeners();
    try {
      final Map<String, dynamic> body = {
        "active": isActive ? 1 : 0,
      };
      body["userCollectibleId"] = userCollectibleId;

      if (newOwnerId != null) {
        body["ownerId"] = newOwnerId;
      }
      if (previousOwnerId != null) {
        // Assuming your backend supports a 'previousOwnerId' field
        body["previousOwnerId"] = previousOwnerId;
      }

      await updateUserCollectibleByUserCollectibleId(body, _appAuthProvider); //
      await loadCollectibles(forceClear: true);
      return true;
    } catch (e) {
      _errorMessage = 'Error updating UserCollectible: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Helper to find a user collectible from the local list
  Map<String, dynamic>? getLocalUserCollectibleById(String userCollectibleId) {
    try {
      return _userCollectibles.firstWhere(
          (uc) => uc['userCollectibleId'].toString() == userCollectibleId,
          orElse: () => null);
    } catch (e) {
      return null;
    }
  }
}

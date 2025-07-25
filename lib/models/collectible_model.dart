import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/app_auth_provider.dart';
import '../api/collectible.dart';
import '../models/user_model.dart';
import '../api/user_collectible.dart';
import '../helpers/sort_data.dart';
import '../helpers/localization_helper.dart';
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
  CollectibleModel(this._appAuthProvider, this.userModel) {
    // This listener will trigger whenever UserModel calls notifyListeners()
    userModel.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    userModel.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    // If the user in UserModel is null (logged out), clear this model's data
    if (userModel.currentUser == null) {
      print("CollectibleModel: User changed/logged out. Clearing data.");
      clearData();
    }
  }

  void clearData() {
    _collectionCollectibles = [];
    _userCollectibles = [];
    _hasLoaded = false;
    _errorMessage = null;
    _loadingMessage = null;
    notifyListeners();
    print("CollectibleModel: Data cleared.");
  }

  String _getSortableString(dynamic value, String languageCode) {
    if (value is Map) {
      // Prioritize the current language, fall back to English, then to an empty string.
      return value[languageCode]?.toString() ?? value['en']?.toString() ?? '';
    }
    return value?.toString() ?? '';
  }

  void _sortCollectibles(String column, String languageCode) {
    _collectionCollectibles.sort((a, b) {
      final String stringA = _getSortableString(a[column], languageCode);
      final String stringB = _getSortableString(b[column], languageCode);
      return stringA.toLowerCase().compareTo(stringB.toLowerCase());
    });
  }

  Future<void> loadCollectibles(
      {bool forceClear = false, String? languageCode}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _loadingMessage = "Collectible Models Loading...";
    if (forceClear) {
      notifyListeners();
    }

    try {
      final String? userId = userModel.currentUser?['userId']?.toString();

      if (userId == null) {
        throw Exception("No user id when loading collectibles");
      }

      final results = await Future.wait([
        getCollectiblesByCollectionId('1', _appAuthProvider),
        getUserCollectiblesByOwnerId(userId, _appAuthProvider)
      ]);

      final dynamic fetchedCollectionData = results[0];
      final dynamic fetchedUserData = results[1];

      if (fetchedCollectionData is List) {
        // Use the helper to decode all necessary fields from JSON strings to Maps.
        _collectionCollectibles = decodeJsonFields(
          fetchedCollectionData,
          [
            'name',
            'description',
            'imageRef',
            'embedRef'
          ], // List all fields that are JSON strings
        );
      } else {
        _collectionCollectibles = [];
      }

      if (fetchedUserData is List) {
        _userCollectibles = fetchedUserData;
      } else {
        _userCollectibles = [];
        print('CollectibleModel: Fetched user data was not a List.');
      }

      _hasLoaded = true;

      // Apply initial sort if a language code is provided
      if (languageCode != null) {
        _sortCollectibles(_sortByName ? "name" : "label", languageCode);
      }
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

  void toggleSortPreference(String languageCode) {
    _sortByName = !_sortByName;
    String columnToSortBy = _sortByName ? "name" : "label";
    try {
      _sortCollectibles(columnToSortBy, languageCode);
    } catch (e) {
      print('Error sorting collectible data: $e');
    }
    notifyListeners();
  }

  Future<void> sortCollectiblesByColumn(
      String column, String languageCode) async {
    if (column == 'name') {
      _sortByName = true;
    } else if (column == 'label') {
      _sortByName = false;
    }

    try {
      _sortCollectibles(column, languageCode);
    } catch (e) {
      print('Error sorting collectible data: $e');
    }
    notifyListeners();
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

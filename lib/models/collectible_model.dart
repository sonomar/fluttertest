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
  bool _sortByName = false;
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
    if (_isLoading || (_hasLoaded && !forceClear)) return;

    if (forceClear) {
      _collectionCollectibles = [];
      _userCollectibles = [];
      _hasLoaded = false;
    }
    _isLoading = true;
    _errorMessage = null;
    _loadingMessage = "Loading...";
    notifyListeners(); // Notify UI it's loading, and lists might be empty if forceClear=true

    try {
      final String? userId = userModel.currentUser?['userId']?.toString();

      if (userId == null) {
        throw Exception("User ID not available from UserModel.");
      }

      // Load collection templates (usually less volatile than user-specific data)
      final dynamic fetchedCollectionData =
          await getCollectiblesByCollectionId('1', _appAuthProvider); //
      if (fetchedCollectionData is List) {
        _collectionCollectibles = fetchedCollectionData;
      } else {
        if (forceClear || _collectionCollectibles.isNotEmpty) {
          _collectionCollectibles = []; // Ensure it's a list
        }
        _errorMessage =
            '${_errorMessage ?? ''} Failed to load collection data: Unexpected format.';
        print('CollectibleModel: Fetched collection data was not a List.');
      }

      // Load user-specific collectibles
      if (userId == null) {
        if (forceClear || _userCollectibles.isNotEmpty) {
          _userCollectibles = []; // Ensure it's a list
        }
        _errorMessage =
            '${_errorMessage ?? ''} User ID not found for user collectibles.';
        print(
            'CollectibleModel: User ID is null, cannot fetch user collectibles.');
      } else {
        final dynamic fetchedUserData =
            await getUserCollectiblesByOwnerId(userId, _appAuthProvider); //
        if (fetchedUserData is List) {
          _userCollectibles = fetchedUserData;
        } else {
          if (forceClear || _userCollectibles.isNotEmpty) {
            _userCollectibles = []; // Ensure it's a list
          }
          _errorMessage =
              '${_errorMessage ?? ''} Failed to load user collectibles: Unexpected format.';
          print('CollectibleModel: Fetched user data was not a List.');
        }
      }
      // print('DEBUG: User collectibles loaded. Count: ${_userCollectibles.length}');
      // print('DEBUG: Collection collectibles loaded. Count: ${_collectionCollectibles.length}');

      // Re-apply sorting if needed
      // if (_collectionCollectibles.isNotEmpty && _sortByName) {
      //   sortCollectiblesByColumn("name");
      // } else if (_collectionCollectibles.isNotEmpty && !_sortByName) {
      //   sortCollectiblesByColumn("label"); // or your default sort
      // }
    } catch (e) {
      _errorMessage = 'Error loading collectible data: ${e.toString()}';
      print('CollectibleModel: Error in loadCollectibles: $e');
      _collectionCollectibles = []; // Ensure lists are empty on error
      _userCollectibles = [];
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI with the final state
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
    // ... (ensure this method calls loadCollectibles(forceClear: true) or manually adds then notifies)
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
    } catch (e) {
      print('Error creating userCollectible data: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateUserCollectibleStatus(String userCollectibleId,
      bool isActive, String? newOwnerId, String? previousOwnerId) async {
    _isLoading = true;
    notifyListeners();
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

      // --- Revised Local State Update Logic ---
      final prefs = await SharedPreferences.getInstance();
      final String? currentModelUserId = prefs.getString('userId');

      final localUserCollectibleIndex = _userCollectibles.indexWhere(
          (uc) => uc['userCollectibleId'].toString() == userCollectibleId);

      if (newOwnerId != null && newOwnerId != currentModelUserId) {
        // This means the current user (who owns this CollectibleModel instance) was the GIVER,
        // and the item has been transferred to someone else (newOwnerId).
        // So, remove it from the giver's local list if it was there.
        if (localUserCollectibleIndex != -1) {
          // Check if the item's owner was indeed this currentModelUserId before removing
          if (_userCollectibles[localUserCollectibleIndex]['ownerId']
                  ?.toString() ==
              currentModelUserId) {
            _userCollectibles.removeAt(localUserCollectibleIndex);
            print(
                "UserCollectible $userCollectibleId removed from local list of giver $currentModelUserId.");
          }
        }
      } else if (newOwnerId == null && localUserCollectibleIndex != -1) {
        // No ownership change, just an active status update for the current owner.
        // (e.g., giver initiates trade by setting active=false, or cancels by setting active=true)
        if (_userCollectibles[localUserCollectibleIndex]['ownerId']
                ?.toString() ==
            currentModelUserId) {
          _userCollectibles[localUserCollectibleIndex]['active'] = isActive;
          print(
              "UserCollectible $userCollectibleId active status updated locally for owner $currentModelUserId.");
        }
      }
      // If newOwnerId IS currentModelUserId (i.e., this user is the RECEIVER):
      // The item wasn't in _userCollectibles to begin with.
      // The `loadCollectibles()` call, which should be made in `ScanScreen._processTrade`
      // AFTER this `updateUserCollectibleStatus` returns true, will fetch the updated
      // list from the backend, including the newly acquired item.

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating UserCollectible: ${e.toString()}';
      print(_errorMessage);
      _isLoading = false;
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

import 'package:flutter/material.dart';
import '../models/app_auth_provider.dart';
import '../models/user_model.dart';
import '../api/mission.dart';
import '../api/mission_user.dart';
import '../helpers/sort_data.dart';

enum MissionSortBy {
  title,
  publicationDate,
}

class MissionModel extends ChangeNotifier {
  AppAuthProvider _appAuthProvider;
  UserModel _userModel;

  List<dynamic> _missions = [];
  List<dynamic> _missionUsers = [];
  bool _isLoading = false;
  String? _errorMessage;
  // Add a flag to track if the initial load has happened.
  bool _hasLoaded = false;

  List<dynamic> get missions => _missions;
  List<dynamic> get missionUsers => _missionUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MissionModel(this._appAuthProvider, this._userModel);

  MissionSortBy _missionSortBy = MissionSortBy.publicationDate;
  MissionSortBy get missionSortBy => _missionSortBy;

  void update(AppAuthProvider authProvider, UserModel userModel) {
    _appAuthProvider = authProvider;
    _userModel = userModel;
  }

  /// MODIFIED: This function now accepts a `forceClear` parameter to control caching.
  Future<void> loadMissions({bool forceClear = false}) async {
    // Prevent re-fetching if already loading or if data has loaded and not forced.
    if (_isLoading) return;
    if (_hasLoaded && !forceClear) return;
    print("MissionModel: loadMissions called with forceClear = $forceClear");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _userModel.currentUser?['userId']?.toString();
      if (userId == null) {
        _errorMessage = 'User ID not found.';
        _missions = [];
        _missionUsers = [];
      } else {
        final dynamic fetchedUserData =
            await getMissionUsersByUserId(userId, _appAuthProvider);

        if (fetchedUserData is List) {
          _missionUsers = fetchedUserData;
          final List<dynamic> fetchedCollectionData = [];
          for (var userMission in _missionUsers) {
            if (userMission != null && userMission["missionId"] != null) {
              var missionData = await getMissionByMissionId(
                  userMission["missionId"].toString(), _appAuthProvider);
              if (missionData != null) {
                fetchedCollectionData.add(missionData);
              }
            }
          }
          _missions = fetchedCollectionData;
        } else {
          _missionUsers = [];
          _missions = [];
          _errorMessage = 'Failed to load user missions: Unexpected format.';
        }
      }

      _hasLoaded = true;
    } catch (e) {
      _errorMessage = 'Error loading mission data: ${e.toString()}';
      _missions = [];
      _missionUsers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMissionProgress(
      dynamic missionUser, int newProgress) async {
    if (missionUser == null || missionUser['missionUserId'] == null) {
      _errorMessage = "Invalid mission user data provided for progress update.";
      notifyListeners();
      return false;
    }

    final missionUserId = missionUser['missionUserId'];
    int? originalProgress;

    final index =
        _missionUsers.indexWhere((mu) => mu['missionUserId'] == missionUserId);

    if (index != -1) {
      originalProgress = _missionUsers[index]['progress'];
      _missionUsers[index]['progress'] = newProgress;
      notifyListeners();
    } else {
      _errorMessage = "Could not find mission user in cache to update.";
      notifyListeners();
      return false;
    }

    try {
      final body = {
        "missionUserId": missionUserId,
        "progress": newProgress,
      };
      final result =
          await updateMissionUserByMissionUserId(body, _appAuthProvider);

      if (result != null) {
        return true;
      } else {
        _errorMessage = "Failed to save mission progress.";
        if (originalProgress != null) {
          _missionUsers[index]['progress'] = originalProgress;
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "An error occurred updating mission progress: $e";
      if (originalProgress != null) {
        _missionUsers[index]['progress'] = originalProgress;
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMissionCompletion(dynamic missionUser) async {
    if (missionUser == null || missionUser['missionUserId'] == null) {
      _errorMessage = "Invalid mission data provided for completion.";
      notifyListeners();
      return false;
    }

    final missionUserId = missionUser['missionUserId'];
    final index =
        _missionUsers.indexWhere((mu) => mu['missionUserId'] == missionUserId);

    if (index != -1) {
      _missionUsers[index]['completed'] = true;
      _missionUsers[index]['dateCompleted'] = DateTime.now().toIso8601String();
      notifyListeners();
    } else {
      _errorMessage = "Could not find mission to complete in cache.";
      notifyListeners();
      return false;
    }

    try {
      final updateBody = {
        "missionUserId": missionUser['missionUserId'],
        "completed": true,
        "dateCompleted": DateTime.now().toIso8601String(),
      };
      final result =
          await updateMissionUserByMissionUserId(updateBody, _appAuthProvider);

      if (result != null) {
        return true;
      } else {
        _errorMessage = "Failed to save completion status to the server.";
        _missionUsers[index]['completed'] = false;
        _missionUsers[index]['dateCompleted'] = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "An error occurred while claiming reward: $e";
      _missionUsers[index]['completed'] = false;
      _missionUsers[index]['dateCompleted'] = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> resetTestMissionProgress() async {
    print("--- DEBUG: Attempting to reset mission progress ---");
    try {
      final body = {
        "missionUserId": 4, // Targeting missionUser with ID 1
        "progress": 13,
        "completed": false,
        "rewardClaimed": false, // Assuming this field exists in your API
      };
      print(
          "--- DEBUG: Sending PATCH request to reset mission with body: $body ---");
      await updateMissionUserByMissionUserId(body, _appAuthProvider);
      print("--- DEBUG: Mission reset request sent successfully ---");
      // Optionally, force a reload of mission data to reflect the change immediately
      await loadMissions(forceClear: true);
    } catch (e) {
      print("--- DEBUG: Failed to reset mission progress: $e ---");
      _errorMessage = "Failed to reset mission progress: $e";
      notifyListeners();
    }
  }
}

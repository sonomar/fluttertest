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

  Future<void> loadMissions() async {
    // Prevent re-fetching if already loading.
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // This now reliably gets the userId from the updated userModel.
      final userId = _userModel.currentUser?['userId']?.toString();
      print('test3: $userId');
      if (userId == null) {
        print(
            'WARNING: userId is null in UserModel. Cannot fetch user missions.');
        _errorMessage = 'User ID not found.';
        _missions = []; // Clear data on failure
        _missionUsers = [];
      } else {
        final dynamic fetchedUserData =
            await getMissionUsersByUserId(userId, _appAuthProvider);

        if (fetchedUserData is List) {
          _missionUsers = fetchedUserData;
          print('test1: $_missionUsers');
          final List<dynamic> fetchedCollectionData = [];
          for (var userMission in _missionUsers) {
            if (userMission != null && userMission["missionId"] != null) {
              var missionData = await getMissionByMissionId(
                  userMission["missionId"].toString(), _appAuthProvider);
              if (missionData != null) {
                print('test2: $missionData');
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

      if (_missions.isNotEmpty) {
        sortData(_missions, "title");
      }
    } catch (e) {
      _errorMessage = 'Error loading mission data: ${e.toString()}';
      _missions = [];
      _missionUsers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMissionCompletion(dynamic missionUser) async {
    if (missionUser == null || missionUser['missionUserId'] == null) {
      _errorMessage = "Invalid mission data provided.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updateBody = {
        "missionUserId": missionUser['missionUserId'],
        "completed": true,
        "dateCompleted": DateTime.now().toIso8601String(),
      };

      // Assumes an API function exists to update the missionUser record.
      final result =
          await updateMissionUserByMissionUserId(updateBody, _appAuthProvider);

      if (result != null) {
        // Refresh the mission list to reflect the change.
        await loadMissions();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Failed to claim reward.";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "An error occurred while claiming reward: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void sortMissions(MissionSortBy sortBy) {
    _missionSortBy = sortBy;
    switch (sortBy) {
      case MissionSortBy.title:
        _missions.sort((a, b) => a['title'].compareTo(b['title']));
        break;
      case MissionSortBy.publicationDate:
      default:
        _missions.sort((a, b) => DateTime.parse(b['publicationDate'])
            .compareTo(DateTime.parse(a['publicationDate'])));
        break;
    }
    notifyListeners();
  }
}

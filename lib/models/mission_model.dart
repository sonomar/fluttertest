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
  // --- CORRECTED: These are no longer final to allow them to be updated. ---
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

  // --- ADDED: An update method to receive new provider instances ---
  void update(AppAuthProvider authProvider, UserModel userModel) {
    _appAuthProvider = authProvider;
    _userModel = userModel;
    // We don't need to call notifyListeners() here, because the logic that
    // calls this method will decide if a data fetch is necessary.
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

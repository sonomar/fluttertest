import 'package:flutter/material.dart';
import '../api/mission.dart';
import '../api/mission_user.dart';
import '../helpers/sort_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MissionModel extends ChangeNotifier {
  List<dynamic> _missions = [];
  List<dynamic> _missionUsers = [];
  bool _isLoading = false;
  bool _sort = false;
  String? _errorMessage;

  List<dynamic> get missions => _missions;
  List<dynamic> get missionUsers => _missionUsers;
  bool get isLoading => _isLoading;
  bool get sort => _sort;
  String? get errorMessage => _errorMessage;

  Future<void> loadMissions() async {
    _isLoading = true;
    _errorMessage = null;
    _sort = false;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      if (userId == null) {
        // If userId is null, we can't fetch user missions.
        // This is where the 'null is not a subtype of String' for userId might come from.
        _missionUsers = []; // Ensure it's an empty list
        print('WARNING: userId is null. Cannot fetch user missions.');
        _errorMessage =
            '${_errorMessage ?? ''} User ID not found.'; // Append error
      } else {
        final dynamic fetchedUserData = await getMissionUsersByUserId(userId);
        print('DEBUG: Fetched user data type: ${fetchedUserData.runtimeType}');
        print('DEBUG: Fetched user data: $fetchedUserData');
        if (fetchedUserData is List) {
          _missionUsers = fetchedUserData;
          final List<dynamic> fetchedCollectionData = [];
          for (int i = 0; i < _missionUsers.length; i++) {
            if (_missionUsers[i] != null &&
                _missionUsers[i]["missionId"] != null) {
              var missionId = await getMissionByMissionId(
                  _missionUsers[i]["missionId"].toString());
              if (missionId != null) {
                fetchedCollectionData.add(missionId);
                // The print statements here are okay, but they will show the list growing
                print(
                    'DEBUG: Fetched collection data (in loop): ${fetchedCollectionData.length} items');
              } else {
                print(
                    'WARNING: Mission with ID ${_missionUsers[i]["missionId"]} not found or returned null.');
              }
            } else {
              print(
                  'WARNING: _missionUsers[$i] or its "missionId" is null/invalid.');
            }
          }
          // --- IMPORTANT FIX HERE ---
          // Assign _missions ONLY after the loop has finished collecting all items.
          _missions = fetchedCollectionData;
          print(
              'DEBUG: Collection missions loaded successfully. Count: ${_missions.length}');
          print(
              'DEBUG: User missions loaded successfully. Count: ${_missionUsers.length}');
        } else {
          _missionUsers = [];
          print(
              'ERROR: getmissionUsersByOwnerId did not return a List. Type: ${fetchedUserData.runtimeType}');
          _errorMessage =
              '${_errorMessage ?? ''} Failed to load user missions: Unexpected format.';
        }
      }
      if (_missions.isNotEmpty) {
        // Use _missions here
        sortData(_missions, "title"); // sortData should handle dynamic content.
        print('DEBUG: Collection missions sorted by title.');
      } else {
        print('WARNING: No collection missions to sort.');
      }
    } catch (e) {
      _errorMessage = 'Error loading mission data: ${e.toString()}';
      print('Error loading mission data: $e');
      _missions = [];
      _missionUsers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

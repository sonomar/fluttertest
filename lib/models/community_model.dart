import 'package:flutter/material.dart';
import '../models/app_auth_provider.dart';
// import '../api/ community.dart;
import '../api/communityChallenge.dart';

class CommunityModel extends ChangeNotifier {
  final AppAuthProvider _appAuthProvider;
  dynamic _communityChallenge = {};
  bool _isLoading = false;
  String? _errorMessage;

  dynamic get communityChallenge => _communityChallenge;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CommunityModel(this._appAuthProvider);

  Future<void> loadCommunityChallenge() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify UI it's loading, and lists might be empty if forceClear=true

    try {
      // Load collection templates (usually less volatile than user-specific data)
      final dynamic fetchedCommunityChallenge =
          await getCommunityChallengeByCommunityChallengeId(
              '1', _appAuthProvider); //
      _communityChallenge = fetchedCommunityChallenge;
      _errorMessage =
          '${_errorMessage ?? ''} Failed to load communityChallenge data: Unexpected format.';
      print('CommunityChallengeModel: Fetched collection data was not a List.');
    } catch (e) {
      _errorMessage = 'Error loading community challenge data: ${e.toString()}';
      print('CommunityChallengeModel: Error in loadCommunityChallenge: $e');
      _communityChallenge = {}; // Ensure lists are empty on error
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI with the final state
    }
  }
}

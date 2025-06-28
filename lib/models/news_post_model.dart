import 'package:flutter/material.dart';
import '../models/app_auth_provider.dart';
import '../api/news_post.dart';

class NewsPostModel with ChangeNotifier {
  final AppAuthProvider _appAuthProvider;

  // The list you want to populate, named according to your request.
  List<dynamic> _getNewsPosts = [];
  bool _isLoading = false;
  String? _errorMessage;
  NewsPostModel(this._appAuthProvider);

  // Public getter for the UI to access the list
  List<dynamic> get newsPosts => _getNewsPosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNewsPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch the three specific news posts in parallel for efficiency
      final List<dynamic> results = await Future.wait([
        getNewsPostByNewsPostId('1', _appAuthProvider),
        getNewsPostByNewsPostId('2', _appAuthProvider),
        getNewsPostByNewsPostId('3', _appAuthProvider),
      ]);

      // Clear the old list
      _getNewsPosts.clear();

      // Process the results
      for (var postData in results) {
        if (postData != null && postData is Map<String, dynamic>) {
          _getNewsPosts.add(postData);
        } else {
          print("NewsProvider: Failed to load or parse a news post.");
        }
      }
    } catch (e, s) {
      _errorMessage = "Error loading news posts: ${e.toString()}";
      print("NewsProvider: $_errorMessage Stack: $s");
      _getNewsPosts = []; // Clear list on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

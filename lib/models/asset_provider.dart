import 'package:flutter/material.dart';
import '../services/asset_cache_service.dart';

class AssetProvider with ChangeNotifier {
  // --- Configuration ---
  // The URL of the specific .gltf file you want to preload for the HomeScreen.
  static const String _homeScreenGltfUrl =
      'https://deins.s3.eu-central-1.amazonaws.com/path/to/your/home_screen_model.gltf'; // IMPORTANT: Replace with your actual URL

  // --- State ---
  bool _isReady = false;
  String? _homeScreenGltfDataUrl;

  // --- Getters ---
  bool get isReady => _isReady;
  String? get homeScreenGltfDataUrl => _homeScreenGltfDataUrl;

  AssetProvider() {
    _initializeAssets();
  }

  Future<void> _initializeAssets() async {
    // Step 1: Initialize the cache service (downloads .bin file if needed).
    await AssetCacheService.instance.initialize();

    // Step 2: Pre-load the specific .gltf for the home screen.
    // This prepares the self-contained data URL and stores it.
    _homeScreenGltfDataUrl = await AssetCacheService.instance
        .getPreparedGltfDataUrl(_homeScreenGltfUrl);

    // Step 3: Notify the app that all essential assets are ready.
    _isReady = true;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../services/asset_cache_service.dart';

class AssetProvider with ChangeNotifier {
  // --- Configuration ---
  static const String _homeScreenGltfUrl =
      'https://deins.s3.eu-central-1.amazonaws.com/Objects3d/kloppocar/KloppoCar_01.gltf';

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
    // --- START OF FIX ---
    // The call to AssetCacheService.instance.initialize() has been removed.
    // We now assume the service is already initialized from main().

    // Pre-load the specific .gltf for the home screen.
    // This will be fast because the .bin file is already cached.
    _homeScreenGltfDataUrl = await AssetCacheService.instance
        .getPreparedGltfDataUrl(_homeScreenGltfUrl);
    // --- END OF FIX ---

    // Notify the app that pre-loading is complete.
    _isReady = true;
    notifyListeners();
  }
}

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

  AssetProvider();

  Future<void> loadInitialAssets() async {
    _homeScreenGltfDataUrl = await AssetCacheService.instance
        .getPreparedGltfDataUrl(_homeScreenGltfUrl);
    _isReady = true;
    notifyListeners();
  }
}
